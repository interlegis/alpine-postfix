FROM alpine:3.23
LABEL MAINTAINER="Fabio Rauber <fabiorauber@gmail.com>"

RUN apk add --no-cache bash postfix postfix-pcre 

COPY conf /etc/postfix

VOLUME ["/var/spool/postfix"]

ENTRYPOINT ["/etc/postfix/postfix-service.sh"]

EXPOSE 25
