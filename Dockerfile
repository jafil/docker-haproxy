FROM oberthur/docker-ubuntu:14.04.4

MAINTAINER Dawid Malinowski <d.malinowski@oberthur.com>

ENV HAPROXY_VERSION=1.6.4

ADD haproxy.cfg /etc/haproxy/haproxy.cfg.template
ADD start-*.sh /bin/

# Prepare image
RUN chmod +x /bin/start-*.sh \
    && add-apt-repository ppa:vbernat/haproxy-1.6 \
    && apt-get update \
    && apt-get install rsyslog haproxy=${HAPROXY_VERSION}* \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && ln -sf /dev/stdout /var/log/haproxy.log

ADD haproxy.rsyslog /etc/rsyslog.conf

ENTRYPOINT ["/bin/start-haproxy.sh"]
