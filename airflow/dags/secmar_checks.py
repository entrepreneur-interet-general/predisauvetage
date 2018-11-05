# -*- coding: utf-8 -*-


def checks():
    return {
        'operations_operations_stats': '''
            select
                nb_operations_stats = nb_operations
            from (
                select count(1) nb_operations
                from operations
            ) operations
            join (
                select count(1) nb_operations_stats
                from operations_stats
            ) operations_stats on true
        ''',
        'operations_operations_points': '''
            select
                nb_operations_points = nb_operations
            from (
                select count(1) nb_operations
                from operations
            ) operations
            join (
                select count(1) nb_operations_points
                from operations_points
            ) operations_points on true
        ''',
        'concerne_snosan': '''
            select
                 nb_operations_snosan = nb_operations_concerne_snosan
            from (
                select count(1) nb_operations_snosan
                from operations op
                join operations_stats stats on stats.operation_id = op.operation_id
                where nombre_flotteurs_plaisance_impliques > 0
                   or nombre_flotteurs_loisirs_nautiques_impliques > 0
                   or nombre_flotteurs_annexe_impliques > 0
                   or op.operation_id in (
                        select op.operation_id
                        from operations op
                        join operations_stats stats on stats.operation_id = op.operation_id and stats.sans_flotteur_implique
                        where op.evenement in (
                         'Sans avarie inexpérience', 'Autre événement', 'Baignade',
                         'Découverte de corps', 'Plongée en apnée', 'Accident en mer',
                         'Isolement par la marée / Envasé', 'Autre accident', 'Blessé EvaMed',
                         'Chasse sous-marine', 'Blessé EvaSan', 'Disparu en mer',
                         'Plongée avec bouteille', 'Sans avarie en dérive', 'Incertitude sur la position',
                         'Homme à la mer', 'Malade EvaMed', 'Ski nautique', 'Accident aéronautique',
                         'Chute falaise / Emporté par une lame', 'Malade EvaSan',
                         'Blessé projection d''une équipe médicale',
                         'Absence d''un moyen de communication'))) snosan
             join (
                select count(1) nb_operations_concerne_snosan
                from operations_stats
                where concerne_snosan
            ) nb_concerne_snosan on true
        ''',
        'operations_count_2017': '''
            select count(1) between 11100 and 11300
            from operations_stats
            where annee = 2017
        ''',
        'dead_people_2017': '''
            select
                sum(os.nombre_personnes_tous_deces_ou_disparues) between 300 and 320
            from operations_stats os
            where annee = 2017
        ''',
        'tss_2017': '''
            select
                count(1) between 45 and 500
            from operations_stats
            where est_dans_dst and annee = 2017
        ''',
        'stm_2017': '''
            select
                count(1) between 650 and 700
            from operations_stats
            where est_dans_stm and annee = 2017
        ''',
        'tss_corse_2016': '''
            select
                count(1) = 0
            from operations_stats
            where date < '2016-12-01' and est_dans_dst and nom_dst = 'dst-corse'
        ''',
        'operations_count_2000_2008': '''
            select
                count(1) between 80000 and 80100
            from operations_stats
            where annee between 2000 and 2008
        ''',
        'unset_tide_data': '''
            select count(1) = 0
            from operations_stats stats
            join operations o on o.operation_id = stats.operation_id
            where stats.distance_cote_metres < 20000
              and o."cross" not in ('Antilles-Guyane', 'Corse', 'Guadeloupe', 'Guyane', 'La Garde', 'La Réunion', 'Martinique', 'Mayotte', 'Nouvelle-Calédonie', 'Polynésie')
              and stats.maree_coefficient is null
        ''',
        'unset_shore_distance': '''
            select count(1) = 0
            from operations_stats stats
            join operations op on op.operation_id = stats.operation_id
            where op.latitude is not null
              and (stats.distance_cote_milles_nautiques is null or stats.distance_cote_metres is null)
        ''',
        'recent_data_last_72h': '''
            select count(1) > 0
            from operations
            where date_heure_reception_alerte > current_date - interval '2 day'
        '''
    }
