FROM ubuntu:20.04

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt update && apt upgrade -y && \
    apt install git golang postgresql curl -y

USER postgres

RUN /etc/init.d/postgresql start &&\
    psql -c "CREATE DATABASE hanabi;" && \
    psql hanabi -c " \
        CREATE USER hanabiuser WITH PASSWORD '1234567890'; \
        GRANT ALL PRIVILEGES ON DATABASE hanabi TO hanabiuser; \
        GRANT USAGE ON SCHEMA public TO hanabiuser; \
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO hanabiuser; \
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO hanabiuser; \
        "


USER root

ENV NVM_DIR="$HOME/.nvm"
RUN mkdir /.nvm
RUN mkdir /hanabi-live
COPY . /hanabi-live/
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash &&\
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" &&\
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" &&\
    nvm install node &&\
    cd /hanabi-live && cp .env_template .env && \
    ./install/install_dependencies.sh &&\
    /etc/init.d/postgresql start &&\
    ./install/install_database_schema.sh &&\
    cd client && npm install && ./build_client.sh &&\
    cd ../server && ./build_server.sh

CMD '/hanabi-live/docker_run.sh'
