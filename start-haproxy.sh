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

# check if we have default backend
if [ "${DEFAULT}" != "" ]; then
    echo ""
    echo "    default_backend ${DEFAULT}" >> /etc/haproxy/haproxy.cfg
else
    # generate acl rules
     for BACKEND in $( env |grep BACKEND_ |sort |awk 'match($0, /BACKEND_[0-9]+/) { print substr( $0, RSTART, RLENGTH )}' |uniq )
     do
        ACL=$( env |grep BACKEND_1 |grep ACL |sed 's/BACKEND_.*=//' )
        echo "    acl is_${BACKEND} ${ACL}" >> /etc/haproxy/haproxy.cfg
        echo "    use_backend ${BACKEND} if is_${BACKEND}" >> /etc/haproxy/haproxy.cfg
        echo "" >> /etc/haproxy/haproxy.cfg
    done
fi

for BACKEND in $( env |grep BACKEND_ |sort |awk 'match($0, /BACKEND_[0-9]+/) { print substr( $0, RSTART, RLENGTH )}' |uniq )
do
  echo "backend ${BACKEND}" >> /etc/haproxy/haproxy.cfg
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
      *REQIREP*)
        REQIREP=$( echo $ELEMENT |sed 's/BACKEND_.*=//' )
        ;;
    esac
  done

  # check if cert was provided
  CERT_PATH="/usr/local/etc/haproxy/certs/${CERTIFICATE}"
  if [ "$CERTIFICATE" != "" ]; then
      PARAMS="ssl crt ${CERT_PATH} verify none"
  else
      PARAMS="verify none"
  fi

  if [ "$( env |grep RESOLVER_ | wc -l )" != "0" ]; then
      DNS="resolvers docker resolve-prefer ipv4"
  fi

  echo "    server ${BACKEND} ${ADDRESS}:${PORT} ${PARAMS} ${DNS}" >> /etc/haproxy/haproxy.cfg

  if [ "${REQIREP}" != "" ]; then
      echo "    ${REQIREP}" >> /etc/haproxy/haproxy.cfg
  fi

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
