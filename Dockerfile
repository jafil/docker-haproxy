FROM oberthur/docker-ubuntu:14.04.4

MAINTAINER Dawid Malinowski <d.malinowski@oberthur.com>

ENV HAPROXY_VERSION=1.6.4 \
    START_MODE=haproxy

ADD haproxy.cfg /etc/haproxy/haproxy.cfg.template
ADD start-*.sh /bin/

# Prepare image
RUN chmod +x /bin/start-*.sh \
    && add-apt-repository ppa:vbernat/haproxy-1.6 \
    && apt-get update \
    && apt-get install rsyslog supervisor haproxy=${HAPROXY_VERSION}* \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && ln -sf /dev/stdout /var/log/haproxy.log

RUN echo "[program:haproxy]\ncommand=/bin/start-%(ENV_START_MODE)s.sh\n#numprocs=1\nstdout_logfile=/dev/fd/1\nstdout_logfile_maxbytes=0\n\n[program:rsyslog]\ncommand=/usr/sbin/rsyslogd -n\nnumprocs=1\nstdout_logfile=/dev/fd/1\nstdout_logfile_maxbytes=0" > /etc/supervisor/conf.d/haproxy.conf

ADD haproxy.rsyslog /etc/rsyslog.conf

ENTRYPOINT [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]
