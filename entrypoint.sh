#!/bin/bash

set -e

echo "=> Configuring Haproxy"

sed -i -e "s/<--LISTENPORT-->/${LISTENPORT}/g" /etc/haproxy/haproxy.cfg
sed -i -e "s/<--SERVER-->/${SERVER}/g" /etc/haproxy/haproxy.cfg
sed -i -e "s/<--SERVERPORT-->/${SERVERPORT}/g" /etc/haproxy/haproxy.cfg

echo "=> Starting Haproxy  ..."

haproxy -db -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid







