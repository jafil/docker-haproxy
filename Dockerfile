FROM alpine:3.2

MAINTAINER Lukasz Czarski <l.czarski@oberthur.com>

ADD haproxy.cfg /etc/haproxy/haproxy.cfg.template
ADD start-haproxy.sh /bin/start-haproxy.sh

# Prepare image
RUN chmod +x /bin/start-haproxy.sh \
    && apk add haproxy bash --update-cache 

ENTRYPOINT ["/bin/start-haproxy.sh"]
