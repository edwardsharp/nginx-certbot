FROM nginx:stable-alpine

RUN apk add --update \
    curl \
    bash \
    certbot \
    tini \
  && rm -rf /var/cache/apk/*

RUN mkdir -p /var/www/letsencrypt/.well-known/acme-challenge

COPY letsencrypt.conf /etc/nginx/snippets/letsencrypt.conf

COPY ssl.conf /etc/nginx/snippets/ssl.conf

EXPOSE 80

EXPOSE 443

VOLUME /etc/letsencrypt

RUN mkdir -p /opt/letsencrypt/bin/

COPY ./bin/ /opt/letsencrypt/bin/

RUN ln -fs /opt/letsencrypt/bin/renew_certs.sh /etc/periodic/daily/

WORKDIR /opt/letsencrypt/bin/

ENTRYPOINT ["/sbin/tini", "--", "/opt/letsencrypt/bin/entrypoint.sh"]
