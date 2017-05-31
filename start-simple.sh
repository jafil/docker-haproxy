#!/bin/bash

# should we pring config
if [ "${PRINT_CONFIG}" == "enabled" ]; then
    cat /etc/haproxy/haproxy.cfg
fi

exec haproxy -q -db -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid
