SELECT
  so.OPERATION_ID operation_id,
  flo.NO_ORDRE numero_ordre,
  scp.LIBELLE pavillon,
  scrf.LIBELLE resultat_flotteur,
  sctp.LIBELLE type_flotteur,
  sccf.LIBELLE categorie_flotteur,
  -- TODO: hash it
  t.NUM_IMMAT numero_immatriculation,
  t.MARQUE marque,
  t.NOM_SERIE nom_serie,
  t.ASSURANCE assurance,
  t.LONGUEUR longueur,
  t.LARGEUR largeur,
  t.JAUGE jauge,
  t.NB_PERSONNE_RECOMMANDE nombre_personne_recommande,
  t.PUISSANCE_MAX_AUT puissance_maximum_autorisee,
  t.SURFACE_VOILURE surface_voilure,
  t.sum_puissance puissance_moteurs,
  t.coque,
  t.materiau,
  t.propulsion,
  t.type_moteur,
  t.type_navire,
  t.utilisation
FROM SECMAR.SEC_OPERATION so
JOIN SECMAR.SEC_FLOTTEUR_IMPLIQUE flo ON so.OPERATION_ID = flo.OPERATION_ID
LEFT JOIN SECMAR.SEC_C_PAVILLON scp on flo.PAVILLON_ID = scp.PAVILLON_ID
LEFT JOIN SECMAR.SEC_C_RESULTAT_FLOT scrf on flo.RESULTAT_FLOTTEUR_ID = scrf.RESULTAT_FLOTTEUR_ID
LEFT JOIN SECMAR.SEC_C_TYPE_FLOTTEUR sctp on flo.TYPE_FLOTTEUR_ID = sctp.TYPE_FLOTTEUR_ID
LEFT JOIN SECMAR.SEC_C_CAT_FLOTTEUR sccf on sctp.CAT_FLOTTEUR_ID = sccf.CAT_FLOTTEUR_ID
LEFT JOIN (
  SELECT
    pi.MARQUE,
    pi.NOM_SERIE,
    piv.NUM_IMMAT,
    piv.NOM_NAVIRE,
    piv.ASSURANCE,
    piv.LONGUEUR,
    piv.LARGEUR,
    piv.JAUGE,
    piv.NB_PERSONNE_RECOMMANDE,
    piv.PUISSANCE_MAX_AUT,
    piv.SURFACE_VOILURE,
    pm.sum_puissance,
    plc.libelle coque,
    pcm.libelle materiau,
    pcp.libelle propulsion,
    pctp.libelle type_moteur,
    pctn.libelle type_navire,
    pcu.libelle utilisation,
    piv.DATE_ADMINISTRATIVE_MAJ "start",
    coalesce(piv2.DATE_ADMINISTRATIVE_MAJ, current_date) "end"
  FROM IMPALA.PLC_IMMAT_VERSION piv
  JOIN IMPALA.PLC_IMMATRICULATION pi on pi.ID_PLC_IMMATRICULATION = piv.ID_PLC_IMMATRICULATION
  LEFT JOIN IMPALA.PLC_CODE_COQUE plc on plc.IDC_COQUE = pi.IDC_COQUE
  LEFT JOIN IMPALA.PLC_CODE_MATERIAU pcm on pcm.IDC_MATERIAU = pi.IDC_MATERIAU
  LEFT JOIN IMPALA.PLC_CODE_PROPULSION pcp on pcp.IDC_PROPULSION = pi.IDC_PROPULSION
  LEFT JOIN IMPALA.PLC_CODE_TYPE_MOTEUR pctp on pctp.IDC_TYPE_MOTEUR = pi.IDC_TYPE_MOTEUR
  LEFT JOIN IMPALA.PLC_CODE_TYPE_NAVIRE pctn on pctn.IDC_TYPE_NAVIRE = pi.IDC_TYPE_NAVIRE
  LEFT JOIN IMPALA.PLC_CODE_UTILISATION pcu on pcu.IDC_UTILISATION = piv.IDC_UTILISATION
  LEFT JOIN IMPALA.PLC_IMMAT_VERSION piv2 on piv2.NUM_IMMAT = piv.NUM_IMMAT and piv2.NUM_VERSION = (piv.NUM_VERSION + 1)
  JOIN (
    select ID_PLC_IMMATRICULATION, num_version, sum(puissance) sum_puissance
    from IMPALA.PLC_MOTEUR
    group by ID_PLC_IMMATRICULATION, num_version
  ) pm on pm.ID_PLC_IMMATRICULATION = piv.ID_PLC_IMMATRICULATION and pm.NUM_VERSION = piv.NUM_VERSION
  ORDER BY piv.NUM_IMMAT, piv.NUM_VERSION
) t ON flo.NUM_IMMAT_FR = t.NUM_IMMAT AND so.DATE_OPERATION BETWEEN t."start" AND t."end"
where so.ETAT_FICHE_ID = 'VALIDE'
