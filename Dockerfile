FROM node:16-buster

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
COPY . /hanabi-live/
RUN /etc/init.d/postgresql start && /hanabi-live/install/install_database_schema.sh
RUN cd /hanabi-live && cp .env_template .env
RUN chown -R node:node /hanabi-live
USER node
RUN cd /hanabi-live && ./install/install_dependencies.sh &&\
    cd client && npm install && ./build_client.sh &&\
    cd ../server && ./build_server.sh

CMD '/hanabi-live/docker_run.sh'
