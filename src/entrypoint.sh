#!/bin/sh
set -e

SCHEDULE="${CRON_SCHEDULE:-0 2 * * *}"

if [ -n "${TZ:-}" ] && [ -f "/usr/share/zoneinfo/$TZ" ]; then
  ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
  echo "$TZ" > /etc/timezone
fi

mkdir -p /var/log
: > /var/log/backup.log

CRON_FILE="/etc/crontabs/root"
{
  echo "SHELL=/bin/sh"
  echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  [ -n "${TZ:-}" ] && echo "TZ=$TZ"
  [ -n "${POSTGRES_HOST:-}" ] && echo "POSTGRES_HOST=$POSTGRES_HOST"
  [ -n "${POSTGRES_PORT:-}" ] && echo "POSTGRES_PORT=$POSTGRES_PORT"
  [ -n "${POSTGRES_DB:-}" ] && echo "POSTGRES_DB=$POSTGRES_DB"
  [ -n "${POSTGRES_USER:-}" ] && echo "POSTGRES_USER=$POSTGRES_USER"
  [ -n "${POSTGRES_PASSWORD:-}" ] && echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD"
  [ -n "${POSTGRES_PASSWORD_FILE:-}" ] && echo "POSTGRES_PASSWORD_FILE=$POSTGRES_PASSWORD_FILE"
  [ -n "${RCLONE_REMOTE_NAME:-}" ] && echo "RCLONE_REMOTE_NAME=$RCLONE_REMOTE_NAME"
  [ -n "${RCLONE_REMOTE_PATH:-}" ] && echo "RCLONE_REMOTE_PATH=$RCLONE_REMOTE_PATH"
  [ -n "${RCLONE_CONFIG_PATH:-}" ] && echo "RCLONE_CONFIG_PATH=$RCLONE_CONFIG_PATH"
  [ -n "${BACKUP_FILENAME:-}" ] && echo "BACKUP_FILENAME=$BACKUP_FILENAME"
  echo "$SCHEDULE /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1"
} > "$CRON_FILE"

exec crond -f -l 2
