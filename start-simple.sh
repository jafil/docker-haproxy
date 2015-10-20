#!/bin/bash

# should we enable logging
if [ "${LOGGING}" == "enabled" ]; then
    (rsyslogd -n &)
fi

# should we pring config
if [ "${PRINT_CONFIG}" == "enabled" ]; then
    cat /etc/haproxy/haproxy.cfg
fi

exec haproxy -db -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid
