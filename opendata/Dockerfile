FROM circleci/node:latest

RUN sudo apt-get update && sudo apt-get install -y \
    wkhtmltopdf \
    python-dev \
    python-pip \
    xvfb

RUN sudo npm install --unsafe-perm -g speccy

RUN sudo pip install open-api-schemas-to-markdown==0.2.1 grip
