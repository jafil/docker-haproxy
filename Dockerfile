FROM oberthur/docker-ubuntu:16.04

MAINTAINER Dawid Malinowski <d.malinowski@oberthur.com>

ENV HAPROXY_VERSION=1.7.1 \
    START_MODE=haproxy

COPY haproxy.cfg /etc/haproxy/haproxy.cfg.template
COPY start-*.sh /bin/
COPY supervisor.conf /etc/supervisor/conf.d/haproxy.conf
COPY supervisord-watchdog /bin/supervisord-watchdog

# Prepare image
RUN chmod +x /bin/start-*.sh \
    && chmod +x /bin/supervisord-watchdog \
    && add-apt-repository ppa:vbernat/haproxy-1.7 \
    && apt-get update \
    && apt-get install rsyslog supervisor haproxy=${HAPROXY_VERSION}* \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && ln -sf /dev/stdout /var/log/haproxy.log

COPY haproxy.rsyslog /etc/rsyslog.conf

ENTRYPOINT ["/usr/bin/supervisord","-n","-c","/etc/supervisor/supervisord.conf"]
