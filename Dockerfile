FROM rawmind/alpine-monit:0.5.20-2
MAINTAINER Fabio Rauber <fabiorauber@gmail.com>

RUN apk add --no-cache bash postfix postfix-pcre rsyslog

COPY conf /etc/postfix
COPY rsyslog.conf /etc/rsyslog.conf

COPY monit-service.conf /opt/monit/etc/conf.d 
