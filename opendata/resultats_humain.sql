select
  srh.OPERATION_ID operation_id,
  sccp.LIBELLE categorie_personne,
  scrh.LIBELLE resultat_humain,
  srh.NB nombre,
  srh.DONT_NB_BLESSE dont_nombre_blesse
from SECMAR.SEC_RESULTAT_HUMAIN srh
join SECMAR.SEC_C_CAT_PERSONNE sccp on srh.CAT_PERSONNE_ID = sccp.CAT_PERSONNE_ID
join SECMAR.SEC_C_RESULTAT_HUMAIN scrh on srh.RESULTAT_HUMAIN_ID = scrh.RESULTAT_HUMAIN_ID
