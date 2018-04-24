# SECMAR Open Data

## Docker
To update the container used to build the documentation, here are the commands:

```sh
export CONTAINER_VERSION=0.0.1
docker build -t antoineaugusti/secmar-opendata-build:$CONTAINER_VERSION .
docker run -it antoineaugusti/secmar-opendata-build:$CONTAINER_VERSION bash
docker push antoineaugusti/secmar-opendata-build:$CONTAINER_VERSION
```

## Notice
This software is available under the MIT license and was developed as part of the [Entrepreneur d'Intérêt Général program](https://entrepreneur-interet-general.etalab.gouv.fr) by the French government.

Projet développé dans le cadre du programme « [Entrepreneur d’intérêt général](https://entrepreneur-interet-general.etalab.gouv.fr) ».
