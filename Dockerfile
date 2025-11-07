FROM postgres:18-alpine

RUN apk add --no-cache \
    rclone \
    tzdata \
    ca-certificates \
    unzip \
    dcron \
    tini

COPY src/backup.sh /usr/local/bin/backup.sh
COPY src/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY src/healthcheck.sh /usr/local/bin/healthcheck.sh

RUN chmod +x /usr/local/bin/backup.sh /usr/local/bin/entrypoint.sh /usr/local/bin/healthcheck.sh

USER root

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]

