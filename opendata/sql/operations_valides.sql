select
  max(OPERATION_ID) operation_id
from SECMAR.SEC_OPERATION
where ETAT_FICHE_ID = 'VALIDE' and NO_SITREP is not null
group by CROSS_ID, extract(year from DATE_HEURE_RECPT_ALERTE), NO_SITREP, ETAT_DATE
