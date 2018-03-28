@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center align-items-center">
        <div class="col-md-4">
            <img src="{{ asset('images/plaisance.jpg') }}" alt="Navires de plaisance" class="img-thumbnail">
        </div>

        <div class="col-md-8">
            <div class="card">
                <div class="card-header">Qu'est-ce que le SNOSAN ?</div>
                <div class="card-body">
                    <p>
                        Le Système National d'Observation de la Sécurité des Activités Nautiques (SNOSAN) est un observatoire interministériel qui répond à la volonté de mieux connaître les caractéristiques des accidents relatifs à la plaisance et aux activités nautiques récréatives et sportives en eaux françaises.
                    </p>
                    <p>
                        Le SNOSAN a pour volonté de mettre en place des actions de prévention pertinentes au niveau national ainsi que d'adopter, lorsque nécessaire, une réglementation relative à la sécurité adaptée au besoin.
                    </p>
                    <p>
                        Le SNOSAN est né par la conclusion d'un protocole d'accord interministériel le 2 juillet 2015 associant :
                    </p>
                    <ul>
                        <li>Le Ministère chargé de la mer</li>
                        <li>Le Ministère chargé des sports</li>
                        <li>Le Ministère de l'Intérieur</li>
                        <li>L'École Nationale de Voile et des Sports Nautiques (ENVSN)</li>
                        <li>La Société Nationale de Sauvetage en Mer (SNSM)</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <div class="row justify-content-center align-items-center mt-5">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">Pourquoi un tel observatoire ?</div>
                <div class="card-body">
                    <p>
                        Une fois un accident survenu, sa prise en charge fait successivement intervenir de nombreux acteurs, publics et privés. Cela rend complexe la remontée uniforme et coordonnée d'informations.
                    </p>
                    <p>
                        Lorsque l'accident a lieu dans la bande des 300 mètres, les victimes sont directement prises en charge par les services départementaux d'intervention et de secours (SDIS) puis, le cas échéant, orientées vers les services hospitaliers. Les centres régionaux opérationnels de surveillance et de sauvetage (CROSS) n'en sont pas nécessairement informés d'où l'existence d'un « chiffre noir » de l'accidentologie dans la bande des 300 mètres.
                    </p>
                    <p>
                    <p>
                        Lorsque l'accident a lieu au-delà de la bande des 300 mètres, les CROSS coordonnent les opérations de sauvetage ou d'assistance. Les acteurs susceptibles d'être mobilisés par les CROSS sont nombreux. Ils disposent – ou non – de leurs propres bases de données, lesquelles recensent les informations considérées comme pertinentes en fonction de leurs propres besoins.
                        <br/>
                        <br/>
                        Ces acteurs sont :
                    </p>
                        <ul>
                            <li>une association reconnue d'utilité public : la SNSM ;</li>
                            <li>les administrations disposant de moyens nautiques ou aériens : la Marine nationale, les Affaires maritimes, l'Armée de l'Air, la Douane, la Gendarmerie nationale, la Police nationale, les SDIS ;</li>
                            <li>voire toute personne se trouvant en mesure d'apporter son concours (marine marchande ou autre plaisancier).</li>
                        </ul>

                        Enfin, une fois l'opération terminée, les CROSS ne sont pas nécessairement destinataires des informations relatives à l'évolution de l'état des personnes secourues ou à l'évaluation des dégâts matériels.
                    </p>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <img src="{{ asset('images/sauvetage.jpg') }}" alt="Exercice de sauvetage SNSM" class="img-thumbnail mb-5">
            <img src="{{ asset('images/helicoptere.jpg') }}" alt="Hélicoptère de la Marine Nationale" class="img-thumbnail mt-5">
        </div>
    </div>
</div>
@endsection
