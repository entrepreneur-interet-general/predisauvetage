# Tables de codes
Les tableaux suivants décrivent les valeurs possibles prises par les colonnes contenant du texte et qui ont un nombre de valeurs possibles important.

## Transition de SeaMIS vers le SNOSAN
Les règles de transition de valeurs d'énumérés provenant de SeaMIS vers le SNOSAN sont [disponibles dans un tableur](https://docs.google.com/spreadsheets/d/1Lg6rWPCb8LRf3Rz9pErcaYQM4XBq2H0G2h7pY2067jo/edit).

## CROSS
Ceci décrit les valeurs possibles dans `operations.cross`.

| Nom du CROSS | Année début usage | Année fin d'usage |
| ------------ | ---------------- | ---------------- |
| Adge | 1984 | 2004 |
| Antilles-Guyane | 1984 | En vigueur |
| Corse | 1985 | En vigueur |
| Corsen | 1985 | En vigueur |
| Étel | 1985 | En vigueur |
| Gris-Nez | 1985 | En vigueur |
| Guadeloupe | 1985 | 1986 |
| Guyane | 1985 | 2014 |
| Jobourg | 1985 | En vigueur |
| La Garde | 1985 | En vigueur |
| La Réunion | 1985 | 2022 |
| Martinique | 1985 | 2009 |
| Mayotte | 2013 | 2021 |
| Nouvelle-Calédonie | 2001 | En vigueur |
| Polynésie | 2000 | En vigueur |
| Soulac | 1985 | 2000 |
| Sud océan Indien | 2021 | En vigueur |

## Événements déclenchant
Ceci décrit les valeurs possibles dans `operations.evenement`.

| Nom de l'événement | Présent dans SECMAR | Présent dans SEAMIS |
| ------------------ | ------------------- | ------------------- |
| Abordage | ✅ | ✅ |
| Absence d'un moyen de communication | ✅ | ❌ |
| Accident aéronautique | ✅ | ✅ |
| Accident corporel | ❌ | ✅ |
| Accident en mer | ✅ | ❌ |
| Acte de piraterie / terrorisme | ✅ | ✅ |
| Autre accident | ✅ | ✅ |
| Autre événement | ✅ | ✅ |
| Avarie de gréement | ❌ | ✅ |
| Avarie de l'appareil à gouverner | ✅ | ✅ |
| Avarie des systèmes de communication | ✅ | ✅ |
| Avarie du système de propulsion | ✅ | ✅ |
| Avarie électrique | ✅ | ✅ |
| Baignade | ✅ | ✅ |
| Blessé EvaMed | ✅ | ✅ |
| Blessé EvaSan | ✅ | ✅ |
| Blessé avec déroutement | ✅ | ✅ |
| Blessé avec soin sans déroutement | ✅ | ✅ |
| Blessé projection d'une équipe médicale | ✅ | ✅ |
| Chasse sous-marine | ✅ | ✅ |
| Chavirement | ✅ | ✅ |
| Chute falaise / Emporté par une lame | ✅ | ✅ |
| Collision | ❌ | ✅ |
| Difficulté de manoeuvre | ✅ | ✅ |
| Disparu en mer | ✅ | ❌ |
| Découverte d'explosif | ✅ | ✅ |
| Découverte de corps | ✅ | ✅ |
| Démâtage | ✅ | ✅ |
| Désarrimage cargaison | ✅ | ✅ |
| Échouement | ✅ | ✅ |
| Encalminage | ✅ | ✅ |
| Engin dangereux à bord | ❌ | ✅ |
| Explosif dans engin | ✅ | ❌ |
| Explosion | ✅ | ✅ |
| Heurt | ✅ | ✅ |
| Homme à la mer | ✅ | ✅ |
| Immigration clandestine | ❌ | ✅ |
| Immobilisé dans engins / hélice engagée | ✅ | ✅ |
| Incendie | ✅ | ✅ |
| Incertitude | ✅ | ✅ |
| Incertitude sur la position | ✅ | ✅ |
| Inexpérience | ❌ | ✅ |
| Isolement par la marée / Envasé | ✅ | ✅ |
| Loisir nautique | ✅ | ❌ |
| Malade EvaMed | ✅ | ✅ |
| Malade EvaSan | ✅ | ✅ |
| Malade avec déroutement | ✅ | ✅ |
| Malade avec soin sans déroutement | ✅ | ✅ |
| Malade projection d'une équipe médicale | ✅ | ✅ |
| Mouillage immobilisé | ❌ | ✅ |
| Naufrage | ❌ | ✅ |
| Panne de carburant | ✅ | ✅ |
| Perte de pontée | ✅ | ✅ |
| Perte de stabilité / Ripage de cargaison | ✅ | ✅ |
| Plongée avec bouteille | ✅ | ✅ |
| Plongée en apnée | ✅ | ✅ |
| Problème médical | ❌ | ✅ |
| Rupture de mouillage | ✅ | ✅ |
| Sans avarie en dérive | ✅ | ✅ |
| Sans avarie inexpérience | ✅ | ✅ |
| Situation indéterminée | ❌ | ✅ |
| Ski nautique | ✅ | ❌ |
| Suicide | ✅ | ✅ |
| Talonnage | ❌ | ✅ |
| Toutes fausses alertes | ✅ | ✅ |
| Transport sanitaire île-continent | ✅ | ✅ |
| Trouble à l'ordre public | ❌ | ✅ |
| Voie d'eau | ✅ | ✅ |

## Moyen d'alerte
Ceci décrit les valeurs possibles dans `operations.moyen_alerte`.

| Moyen d'alerte | Présent dans SECMAR | Présent dans SEAMIS |
| -------------- | ------------------- | ------------------- |
| Autre moyen d'alerte | ✅ | ✅ |
| Autre signal réglementaire | ✅ | ✅ |
| Balise 121,5 Mhz | ✅ | ✅ |
| Balise de détresse | ✅ | ✅ |
| Balise de détresse ELT | ❌ | ✅ |
| Balise de détresse EPIRB | ❌ | ✅ |
| Balise de détresse PLB | ❌ | ✅ |
| Balise de sûreté des navires | ✅ | ✅ |
| Email | ❌ | ✅ |
| HF | ✅ | ❌ |  
| Inmarsat C | ❌ | ✅ |
| MF/HF ASN | ✅ | ✅ |
| MF/HF phonie | ✅ | ✅ |
| MOB ASN | ❌ | ✅ |
| Mob AIS | ❌ | ✅ |
| SART | ❌ | ✅ |
| SSAS | ❌ | ✅ |
| Signal pyrotechnique | ✅ | ✅ |
| Système individuel d'alerte | ❌ | ✅ |
| Télex | ✅ | ❌ |
| Télécopie | ✅ | ✅ |
| Téléphone fixe | ✅ | ✅ |
| Téléphone fixe 196 | ❌ | ✅ |
| Téléphone mobile | ❌ | ✅ |
| Téléphone mobile à terre | ✅ | ✅ |
| Téléphone à la mer / GSM | ✅ | ✅ |
| Téléphone à la mer / satellite | ✅ | ✅ |
| Téléphone à terre | ✅ | ❌ |
| Téléphonie mobile 196 | ❌ | ✅ |
| VHF | ✅ | ❌ |
| VHF AIS | ❌ | ✅ |
| VHF ASN | ✅ | ✅ |
| VHF phonie | ✅ | ✅ |

## Qui alerte
Ceci décrit les valeurs possibles dans `operations.qui_alerte`.

| Moyen d'alerte | Présent dans SECMAR | Présent dans SEAMIS |
| -------------- | ------------------- | ------------------- |
| ARCC ARSC | ❌ | ✅ |
| Affaires maritimes / CSN | ✅ | ✅ |
| Affaires maritimes / phares et balises | ✅ | ✅ |
| Agent maritime | ❌ | ✅ |
| Ambassade / Consulat | ✅ | ✅ |
| Ambassade / consulat | ❌ | ✅ |
| Armateur | ✅ | ✅ |
| Armée de terre-air | ✅ | ❌ |  
| Autorité médicale étrangère | ✅ | ❌ |
| Autre administration civile | ✅ | ✅ |
| Autre autorité civile française à terre | ✅ | ✅ |
| Autre autorité étrangère | ✅ | ✅ |
| Autre aéronef | ✅ | ✅ |
| Autre navire à la mer | ✅ | ✅ |
| Autre organisme ou personne privée | ✅ | ✅ |
| Aéronef administratif | ✅ | ✅ |
| Aéronef civil | ❌ | ✅ |
| Aéronef impliqué | ✅ | ✅ |
| Aéronef militaire | ✅ | ✅ |
| CCMM | ✅ | ✅ |
| CODIS / SDIS / CTA | ✅ | ✅ |
| COGIC | ✅ | ❌ |
| COGIC interministériel | ❌ | ✅ |
| CORG / Gendarmerie nationale | ✅ | ✅ |
| COZ / Sécurité civile | ✅ | ✅ |
| CROSS / MRCC | ✅ | ✅ |
| Centre secours locaux (caserne pompier) | ✅ | ✅ |
| Cibiste | ✅ | ❌ |
| Collectivité locale / Mairie | ✅ | ✅ |
| Comité de course | ✅ | ✅ |
| Compagnie aérienne | ✅ | ❌ |  
| Compagnie d'assurance | ✅ | ✅ |
| Contrôle aérien | ❌ | ✅ |
| DRAM et DDAM | ✅ | ❌ |  
| Douane | ✅ | ✅ |
| École de voile | ✅ | ✅ |
| EPSHOM | ✅ | ❌ |  
| Famille / Proche | ✅ | ✅ |
| Gendarmerie maritime | ✅ | ✅ |
| Gendarmerie nationale | ✅ | ✅ |
| IMMARSAT A | ✅ | ❌ |  
| IMMARSAT C | ✅ | ❌ |  
| Loueur de bateaux | ✅ | ✅ |
| MCC COSPAS-SARSAT | ✅ | ✅ |
| MCC SARSAT COAPAS 121,5-243 | ✅ | ✅ |
| MCC SARSAT COSPAS 406 | ✅ | ✅ |
| MCC Sarsat – Cospas | ✅ | ✅ |
| MRCC | ✅ | ✅ |
| Marine nationale | ✅ | ✅ |
| MiMer | ✅ | ❌ |
| Navire Marine nationale | ✅ | ✅ |
| Navire administration civile | ✅ | ✅ |
| Navire de commerce | ✅ | ✅ |
| Navire de gendarmerie | ✅ | ✅ |
| Navire de plaisance | ✅ | ✅ |
| Navire de pêche | ✅ | ✅ |
| Navire de sauvetage | ✅ | ✅ |
| Navire impliqué | ✅ | ✅ |
| Organisme professionnel / Pêcheur | ✅ | ✅ |
| Phares et balises | ✅ | ✅ |
| Pilotage | ✅ | ✅ |
| Police | ✅ | ✅ |
| Port | ✅ | ✅ |
| Poste de plage | ✅ | ✅ |
| PreMar | ✅ | ❌ |  
| Propriétaire | ❌ | ✅ |
| Préfecture | ❌ | ✅ |
| Préfecture terrestre ou maritime | ✅ | ✅ |
| RCC / RSC | ✅ | ✅ |
| RCC et RSC | ✅ | ✅ |
| Radio amateur | ❌ | ✅ |
| Radio-amateur | ✅ | ❌ |
| SAM ou station AffMar | ✅ | ❌ |
| SAMU | ✅ | ✅ |
| SAMU Coordination médicale maritime | ✅ | ✅ |
| SCMM | ✅ | ✅ |
| SHOM | ❌ | ✅ |
| SNSM | ✅ | ✅ |
| Service de géolocalisation privé | ✅ | ✅ |
| Station radio-maritime | ✅ | ✅ |
| Support de plongée | ✅ | ✅ |
| Sémaphore | ✅ | ✅ |
| Témoin | ✅ | ✅ |


## Bilan humain
Ceci décrit les valeurs possibles dans `resultats_humain.resultat_humain`.

| Description du bilan humain | Présent dans SECMAR | Présent dans SEAMIS |
| --------------------------- | ------------------- | ------------------- |
| Inconnu | ❌ | ✅ |
| Personne assistée | ✅ | ✅ |
| Personne blessée | ❌ | ✅ |
| Personne décédée | ✅ | ✅ |
| Personne décédée accidentellement | ✅ | ✅ |
| Personne décédée naturellement | ✅ | ✅ |
| Personne disparue | ✅ | ✅ |
| Personne impliquée dans fausse alerte | ✅ | ✅ |
| Personne indemne | ❌ | ✅ |
| Personne malade | ❌ | ✅ |
| Personne retrouvée | ✅ | ✅ |
| Personne secourue | ✅ | ✅ |
| Personne tirée d'affaire seule | ✅ | ✅ |

## Autorités des moyens
Ceci décrit les valeurs possibles dans `moyens.autorite_moyen`.

| Autorité dont le moyen a été engagé | Présent dans SECMAR | Présent dans SEAMIS |
| ----------------------------------- | ------------------- | ------------------- |
| Administration étrangère | ✅ | ✅ |
| Affaires maritimes | ✅ | ✅ |
| Armateur | ✅ | ✅ |
| Armée de l'air | ✅ | ✅ |
| Armée de terre | ✅ | ✅ |
| Autorité portuaire | ✅ | ✅ |
| Autre | ✅ | ✅ |
| Autre administration française | ✅ | ❌ |
| Autre autorité | ❌ | ✅ |
| Autre organisme médical | ✅ | ✅ |
| Aviation civile | ❌ | ✅ |
| Centre de consultation médical | ✅ | ✅ |
| Compagnie aérienne | ✅ | ❌ |
| COZ / Sécurité civile | ✅ | ✅ |
| Douane | ✅ | ✅ |
| Entreprises d'assistance maritime | ❌ | ✅ |
| Entreprises de remorquage et de dépannage | ✅ | ✅ |
| Établissement public parc marin | ❌ | ✅ |
| FEPSM | ❌ | ✅ |
| Gendarmerie Marine | ❌ | ✅ |
| Gendarmerie Maritime | ✅ | ✅ |
| Gendarmerie Nationale | ✅ | ✅ |
| Gendarmerie nationale ou maritime | ✅ | ❌ |
| Mairie / Collectivité locale | ✅ | ✅ |
| Marine nationale | ✅ | ✅ |
| Navire sur zone | ✅ | ❌ |
| Pilotage | ✅ | ✅ |
| Police nationale / Police municipale | ❌ | ✅ |
| Police-CRS | ✅ | ✅ |
| Privé / Particulier | ✅ | ✅ |
| Proche / Famille | ✅ | ✅ |
| SAMU côtier | ✅ | ✅ |
| Santé | ❌ | ✅ |
| SCMM | ✅ | ✅ |
| SCMM / SAMU côtier | ✅ | ✅ |
| Services départementaux d'incendie et de secours | ✅ | ✅ |
| SNSM | ✅ | ✅ |
| Station radio côtière | ✅ | ❌ |

## Types précis de flotteurs
Ceci décrit les valeurs possibles dans `flotteurs.type_flotteur`.

| Type de flotteur | Présent dans SECMAR | Présent dans SEAMIS |
| ---------------- | ------------------- | ------------------- |
| Administration / Armée | ✅ | ✅ |
| Aéronef de tourisme | ✅ | ✅ |
| Annexe | ✅ | ✅ |
| Autre aéronef | ✅ | ✅ |
| Autre loisir nautique | ✅ | ✅ |
| Canoë / Kayak / Aviron | ✅ | ✅ |
| Commerce | ✅ | ❌ |
| Conchylicole / Aquacole | ✅ | ✅ |
| Engin de plage | ✅ | ❌ |
| Engin radeau de survie | ❌ | ✅ |
| Fluvial / Péniche | ✅ | ✅ |
| Hélicoptère | ❌ | ✅ |
| Kitesurf | ✅ | ✅ |
| Navire à passagers | ✅ | ✅ |
| Navire de charge ou de servitude | ✅ | ✅ |
| Navire de plaisance à moteur | ✅ | ❌ |
| Navire de plaisance à moteur type off-shore | ✅ | ❌ |
| Parapente | ❌ | ✅ |
| Pêche | ✅ | ✅ |
| Plaisance à moteur | ❌ | ✅ |
| Plaisance à moteur < 8m | ✅ | ✅ |
| Plaisance à moteur > 8m | ✅ | ✅ |
| Plaisance à voile | ✅ | ✅ |
| Plaisance voile légère | ✅ | ✅ |
| Planche à voile | ✅ | ✅ |
| Plate-forme de forage off-shore | ✅ | ❌ |
| Ski nautique | ✅ | ❌ |
| Stand up paddle | ❌ | ✅ |
| Surf | ✅ | ✅ |
| ULM | ❌ | ✅ |
| Véhicule nautique à moteur | ✅ | ✅ |

## Ports de référence pour la marée
Ceci décrit les valeurs possibles dans `operations_stats.maree_port`.

![Carte des ports](https://i.imgur.com/TtmZmCc.png)

| Nom du port |
| ------------- |
| Arcachon Eyrac |
| Barfleur |
| Boucau-Bayonne |
| Boulogne-sur-Mer |
| Brest |
| Calais |
| Cherbourg |
| Concarneau |
| Dielette |
| Dieppe |
| Dunkerque |
| Etretat |
| Fecamp |
| Granville |
| La Rochelle-Pallice |
| Le Havre |
| Le Touquet |
| Le Treport |
| Les Sables-d'Olonne |
| Ouistreham |
| Paimpol |
| Pointe de Grave |
| Port-Navalo |
| Port-Tudy |
| Portbail |
| Roscoff |
| Saint-Jean-de-Luz |
| Saint-Malo |
| Saint-Nazaire |
| Vieux-Boucau |
| Wissant |
