FROM debian:jessie
MAINTAINER Roberto Aguilar <roberto.c.aguilar@gmail.com>

RUN apt-get update && apt-get install -y apache2-utils openssl

ADD files/ /
RUN chmod +x /usr/local/bin/*

ADD docker-compose.yml /
ADD docker-compose-tools.yml /

RUN mkdir -p /auth && touch /auth/htpasswd

VOLUME /auth
VOLUME /certs

CMD ["/usr/local/bin/gen-ssl-cert"]
