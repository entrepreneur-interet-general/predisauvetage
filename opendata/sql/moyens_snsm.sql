insert into moyens_snsm
select
  *,
  (nombre_vedettes_2e_ou_3e_classe_engages + nombre_canots_tout_temps_engages + nombre_vedettes_1ere_classe_engages + nombre_semi_rigides_engages + nombre_vedettes_4e_classe_engages) nombre_moyens_nautiques_engages,
  nombre_patrouilles_engages nombre_moyens_terrestres_engages
from (
  select
    operation_id,
    sum((moyen in ('Embarcation légère de sauvetage (pneumatique,...)', 'Autre embarcation légère (pneumat...)'))::int) nombre_semi_rigides_engages,
    sum((moyen = 'Vedette de 1re classe')::int) nombre_vedettes_1ere_classe_engages,
    sum((moyen = 'Vedette de 2e ou 3e classe')::int) nombre_vedettes_2e_ou_3e_classe_engages,
    sum((moyen = 'Vedette de 4e classe')::int) nombre_vedettes_4e_classe_engages,
    sum((moyen = 'Canot tout-temps')::int) nombre_canots_tout_temps_engages,
    sum((moyen = 'Patrouille')::int) nombre_patrouilles_engages
  from moyens
  where autorite_moyen = 'SNSM'
    and domaine_action in ('Nautique', 'Terrestre')
  group by operation_id
) t;
