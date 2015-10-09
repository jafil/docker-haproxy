#!/bin/bash

set -e

echo "=> Configuring Haproxy"

cp -v /etc/haproxy/haproxy.cfg.template /etc/haproxy/haproxy.cfg

sed -i -e "s/<--LISTENPORT-->/${LISTENPORT}/g" /etc/haproxy/haproxy.cfg
sed -i -e "s/<--MODE-->/${MODE}/g" /etc/haproxy/haproxy.cfg

COUNTER=0
for BACKEND in $( env |grep BACKEND_ |sed 's/BACKEND_.*=//' )
do
    let COUNTER=COUNTER+1;
    echo "    server backend_${COUNTER} ${BACKEND}" >> /etc/haproxy/haproxy.cfg
done


echo "=> Starting Haproxy  ..."

exec haproxy -db -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid
