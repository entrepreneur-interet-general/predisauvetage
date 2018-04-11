select
  so.OPERATION_ID,
  scpq.LIBELLE pourquoi_alerte,
  scma.LIBELLE moyen_alerte,
  scqa.LIBELLE qui_alerte,
  sccqa.LIBELLE categorie_qui_alerte,
  scc.LIBELLE cross,
  scd.LIBELLE departement,
  scd.B_METROPOLITAIN est_metropolitain,
  sce.LIBELLE evenement,
  scce.LIBELLE categorie_evenement,
  sca.LIBELLE autorite,
  sca.LIBELLE sous_autorite,
  sczr.LIBELLE zone_responsabilite,
  so.LATITUDE latitude,
  so.LONGITUDE longitude,
  so.VENT_DIRECTION vent_direction,
  so.VENT_FORCE vent_force,
  so.MER_FORCE mer_force,
  so.DATE_HEURE_RECPT_ALERTE date_heure_reception_alerte,
  so.DATE_HEURE_FIN_OPERATION,
  so.NO_SITREP numero_sitrep,
  null cross_sitrep,
  null fuseau_horaire
from SECMAR.SEC_OPERATION so
join SECMAR.SEC_C_POURQUOI_ALERTE scpq on so.POURQUOI_ALERTE_ID = scpq.POURQUOI_ALERTE_ID
join SECMAR.SEC_C_MOYEN_ALERTE scma on so.MOYEN_ALERTE_ID = scma.MOYEN_ALERTE_ID
join SECMAR.SEC_C_QUI_ALERTE scqa on so.QUI_ALERTE_ID = scqa.QUI_ALERTE_ID
join SECMAR.SEC_C_CAT_QUI_ALERTE sccqa on scqa.CAT_QUI_ALERTE_ID = sccqa.CAT_QUI_ALERTE_ID
join SECMAR.SEC_C_CROSS scc on so.CROSS_ID = scc.CROSS_ID
left join SECMAR.SEC_C_DEPARTEMENT scd on so.DEPT_COTIER_ID = scd.DEPT_ID
join SECMAR.SEC_C_EVENEMENT sce on sce.EVENEMENT_ID = so.EVENEMENT_ID
join SECMAR.SEC_C_CAT_EVENEMENT scce on sce.CAT_EVENEMENT_ID = scce.CAT_EVENEMENT_ID
join SECMAR.SEC_C_AUTORITE sca on so.AUTORITE_ID = sca.AUTORITE_ID
left join secmar.SEC_C_AUTORITE sca2 on so.AUTORITE_ID_2 = sca2.AUTORITE_ID
join secmar.SEC_C_ZONE_RESP sczr on so.ZONE_RESP_ID = sczr.ZONE_RESP_ID
