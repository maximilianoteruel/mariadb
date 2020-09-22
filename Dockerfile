FROM mariadb:10.5.4-focal

WORKDIR /usr/src/app

ENV TZ=America/Argentina/Buenos_Aires
ENV MYSQL_INITDB_SKIP_TZINFO=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends cron && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY . .

RUN chmod +x -R scripts && \
    mkdir -p log && \
    touch log/cron.log && \
    touch log/mysql.log && \
    mkdir -p backup && \
    mkdir -p backup/dump

CMD ["scripts/init.sh"]

