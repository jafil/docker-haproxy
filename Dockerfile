FROM alpine:3.2

MAINTAINER Lukasz Czarski <l.czarski@gmail.com>

# Prepare image
RUN apk add haproxy bash --update-cache 

ADD haproxy.cfg /etc/haproxy/haproxy.cfg
ADD entrypoint.sh /bin/entrypoint.sh

RUN chmod +x /bin/entrypoint.sh
WORKDIR /etc/haproxy
ENTRYPOINT ["/bin/entrypoint.sh"]

