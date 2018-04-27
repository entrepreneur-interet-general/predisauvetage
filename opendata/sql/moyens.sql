select
  smm.OPERATION_ID operation_id,
  smm.NO_ORDRE numero_ordre,
  scm.LIBELLE moyen,
  sccm.LIBELLE categorie_moyen,
  scda.LIBELLE domaine_action,
  scam.LIBELLE autorite_moyen,
  smm.DATE_HEURE_DEPART date_heure_debut,
  smm.DATE_HEURE_DEPART + smm.duree date_heure_fin
from SECMAR.SEC_MOYEN_MEO smm
join SECMAR.SEC_OPERATION so on so.OPERATION_ID = smm.OPERATION_ID and so.ETAT_FICHE_ID = 'VALIDE'
join SECMAR.SEC_C_MOYEN scm on smm.MOYEN_ID = scm.MOYEN_ID
join SECMAR.SEC_C_CAT_MOYEN sccm on scm.CAT_MOYEN_ID = sccm.CAT_MOYEN_ID
join SECMAR.SEC_C_DOMAINE_ACTION scda on scm.DOMAINE_ACTION_ID = scda.DOMAINE_ACTION_ID
join SECMAR.SEC_C_AUTORITE_MOYEN scam on smm.AUTORITE_MOYEN_ID = scam.AUTORITE_MOYEN_ID
