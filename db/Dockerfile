FROM postgres:11

RUN apt-get update
RUN apt-get install -y postgresql-plpython3-11
RUN apt-get install -y python3-pip
RUN pip3 install minio

COPY ./db/src /docker-entrypoint-initdb.d
