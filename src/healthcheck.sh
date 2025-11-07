#!/bin/sh

if ! ps aux | grep -v grep | grep -q "[c]rond"; then
  exit 1
fi

if [ ! -d /var/log ] || [ ! -w /var/log ]; then
  exit 1
fi

touch /var/log/.healthcheck 2>/dev/null || exit 1

exit 0

