#!/bin/bash

MULTICONFIG="-f /etc/haproxy/haproxy.cfg"
if [ ! -e "/etc/haproxy/haproxy.cfg" ]; then
  echo "You must have /etc/haproxy/haproxy.cfg"
  exit 1
fi

# add tcp if exists
if [ -e "/etc/haproxy/conf.d/tcp.cfg" ]; then
  MULTICONFIG="${MULTICONFIG} -f /etc/haproxy/conf.d/tcp.cfg"
fi

# add http if exists
if [ -e "/etc/haproxy/conf.d/http.cfg" ]; then
  MULTICONFIG="${MULTICONFIG} -f /etc/haproxy/conf.d/http.cfg"
fi

# add https if exists
if [ -e "/etc/haproxy/conf.d/https.cfg" ]; then
  MULTICONFIG="${MULTICONFIG} -f /etc/haproxy/conf.d/https.cfg"
fi

# add backends if exists
for FILE in $( ls /etc/haproxy/conf.d/backends/*.cfg | sort -n); do
  MULTICONFIG="${MULTICONFIG} -f ${FILE}"
done

exec haproxy -db ${MULTICONFIG} -p /var/run/haproxy.pid
