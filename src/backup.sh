#!/bin/sh
set -e

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

: "${POSTGRES_HOST:?Set POSTGRES_HOST}"
: "${POSTGRES_DB:?Set POSTGRES_DB}"
: "${POSTGRES_USER:?Set POSTGRES_USER}"
: "${RCLONE_REMOTE_NAME:?Set RCLONE_REMOTE_NAME}"
: "${RCLONE_REMOTE_PATH:?Set RCLONE_REMOTE_PATH}"

if [ -n "${POSTGRES_PASSWORD_FILE:-}" ] && [ -f "$POSTGRES_PASSWORD_FILE" ]; then
  export POSTGRES_PASSWORD="$(cat "$POSTGRES_PASSWORD_FILE")"
fi

if [ -n "${POSTGRES_PASSWORD:-}" ]; then
  export PGPASSWORD="$POSTGRES_PASSWORD"
fi

if [ -n "${RCLONE_CONFIG_PATH:-}" ] && [ -f "$RCLONE_CONFIG_PATH" ]; then
  mkdir -p /root/.config/rclone
  cp "$RCLONE_CONFIG_PATH" /root/.config/rclone/rclone.conf
fi

: "${BACKUP_FILENAME:?Set BACKUP_FILENAME}"

TARGET="${RCLONE_REMOTE_NAME}:${RCLONE_REMOTE_PATH%/}/$BACKUP_FILENAME"

log "Starting backup to $TARGET"

pg_dump \
  -h "$POSTGRES_HOST" \
  -p "${POSTGRES_PORT:-5432}" \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" \
  -Fc \
  -Z 9 | rclone rcat "$TARGET"

log "Backup finished"

