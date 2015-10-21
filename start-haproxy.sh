#!/bin/bash

set -e

echo "=> Configuring Haproxy"

cp -v /etc/haproxy/haproxy.cfg.template /etc/haproxy/haproxy.cfg
sed -i -e "s/<--MODE-->/${MODE}/g" /etc/haproxy/haproxy.cfg

# check if we have server certificate
if [ "${CERTIFICATE}" != "" ]; then
    # check if we have server ca
    if [ "${CA}" != "" ]; then
        echo "    bind *:${LISTENPORT} ssl crt /usr/local/etc/haproxy/certs/${CERTIFICATE} /usr/local/etc/haproxy/certs/${CA} verify ${VERIFY}" >> /etc/haproxy/haproxy.cfg
    else
        echo "    bind *:${LISTENPORT} ssl crt /usr/local/etc/haproxy/certs/${CERTIFICATE}" >> /etc/haproxy/haproxy.cfg
    fi
else
    echo "    bind *:${LISTENPORT}" >> /etc/haproxy/haproxy.cfg
fi

# remove headers that expose security-sensitive information
if [ "${MODE}" == "http" ]; then
    echo "    rspidel ^Server:.*$" >> /etc/haproxy/haproxy.cfg
    echo "    rspidel ^X-Powered-By:.*$" >> /etc/haproxy/haproxy.cfg
    echo "    rspidel ^X-AspNet-Version:.*$" >> /etc/haproxy/haproxy.cfg
fi

# check if we have default backend
if [ "${DEFAULT}" != "" ]; then
    echo ""
    echo "    default_backend ${DEFAULT}" >> /etc/haproxy/haproxy.cfg
    echo "" >> /etc/haproxy/haproxy.cfg
fi

# generate acl rules
for BACKEND in $( env |grep BACKEND_ |sort |awk 'match($0, /BACKEND_[0-9]+/) { print substr( $0, RSTART, RLENGTH )}' |uniq )
do
    ACL=$( env |grep ${BACKEND} |grep ACL |sed 's/BACKEND_.*=//' )

    if [ "${ACL}" != "" ]; then
        echo "    acl is_${BACKEND} ${ACL}" >> /etc/haproxy/haproxy.cfg
        echo "    use_backend ${BACKEND} if is_${BACKEND}" >> /etc/haproxy/haproxy.cfg
        echo "" >> /etc/haproxy/haproxy.cfg
    fi
done

for BACKEND in $( env |grep BACKEND_ |sort |awk 'match($0, /BACKEND_[0-9]+/) { print substr( $0, RSTART, RLENGTH )}' |uniq )
do
  echo "backend ${BACKEND}" >> /etc/haproxy/haproxy.cfg
  unset ADDRESS PORT CERTIFICATE
  for ELEMENT in $( env |grep ${BACKEND} |sort )
  do
    case "$ELEMENT" in
      *ADDRESS*)
        ADDRESS=$( echo $ELEMENT |sed 's/BACKEND_.*=//' )
        ;;
      *PORT*)
        PORT=$( echo $ELEMENT |sed 's/BACKEND_.*=//' )
        ;;
      *CERTIFICATE*)
        CERTIFICATE=$( echo $ELEMENT |sed 's/BACKEND_.*=//' )
        ;;
      *OVERRIDE_HOST*)
        OVERRIDE_HOST=$( echo $ELEMENT |sed 's/BACKEND_.*=//' )
        ;;
    esac
  done

  # check if cert was provided
  CERT_PATH="/usr/local/etc/haproxy/certs/${CERTIFICATE}"
  if [ "$CERTIFICATE" != "" ]; then
      PARAMS="check ssl crt ${CERT_PATH} verify none"
  else
      PARAMS="check"
  fi

  if [ "$( env |grep RESOLVER_ | wc -l )" != "0" ]; then
      DNS="resolvers docker resolve-prefer ipv4"
  fi

  # override host header
  if [ "${OVERRIDE_HOST}" != "" ]; then
     echo "    reqirep ^Host: Host:\ ${OVERRIDE_HOST}" >> /etc/haproxy/haproxy.cfg
  fi

  # generate reqrep rules
  REQREP=$( env |grep ${BACKEND} |grep REQREP |sed 's/BACKEND_.*=//' )
  if [ "${REQREP}" != "" ]; then
     echo "    ${REQREP}" >> /etc/haproxy/haproxy.cfg
  fi

  echo "    server ${BACKEND} ${ADDRESS}:${PORT} ${PARAMS} ${DNS}" >> /etc/haproxy/haproxy.cfg

done

if [ "$( env |grep RESOLVER_ | wc -l )" != "0" ]; then

    echo "" >> /etc/haproxy/haproxy.cfg
    echo "resolvers docker" >> /etc/haproxy/haproxy.cfg

         for RESOLVER in $( env |grep RESOLVER_ |sort |awk 'match($0, /RESOLVER_[0-9]+/) { print substr( $0, RSTART, RLENGTH )}' |uniq )
         do
              for ELEMENT in $( env |grep ${RESOLVER} |sort )
              do
                case "$ELEMENT" in
                  *VALUE*)
                    VALUE=$( echo $ELEMENT |sed 's/RESOLVER_.*=//' )
                    ;;
                esac
              done
              echo "    nameserver ${RESOLVER} ${VALUE}" >> /etc/haproxy/haproxy.cfg
         done

    echo "    resolve_retries       3" >> /etc/haproxy/haproxy.cfg
    echo "    timeout retry         1s" >> /etc/haproxy/haproxy.cfg
    echo "    hold valid           10s" >> /etc/haproxy/haproxy.cfg

fi

# should we enable logging
if [ "${LOGGING}" == "enabled" ]; then
    (rsyslogd -n &)
fi

# should we pring config
if [ "${PRINT_CONFIG}" == "enabled" ]; then
    env |grep BACKEND_
    cat /etc/haproxy/haproxy.cfg
fi

exec haproxy -db -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid
