# nginx-certbot

YET ANOTHER docker-ized nginx proxy with let's encrypt certbot for ssl certz!

on start this image will check if installed certs for the list of `DOMAINS` exist and if they do __not__ then run `certbot` in standalone (so nginx doesn't exit complaining about non-existing files). this image also uses a daily cron to check/update ssl certificates and (if new certs are generated) reload nginx. all-in-one container; w00t!

this container will only request certificates after `certbot --dry-run` runs successfully; helping to avoid burning through certificate requests. 

### example

__docker-compose.yml__ 

_notes_ 

1. make sure dir `./letsencrypt` exists  
2. set EMAIL environment var to your email address
3. DOMAINS var can be semicolon (;) and comma (,) seperated (for example: `DOMAINS=www.example.net,example.net;api.foobar.site,assets.foobar.site`)

```yml
version: "2"
services:
  nginx-certbot:
    image: 3dwardsharp/nginx-certbot
    environment:
      - DOMAINS=demo.youoke.party,youoke.party
      - EMAIL=hello@youoke.party
      - BASE_SERVER=youoke.party
      - BASE_SERVER_PROXY=helloworld
      - BASE_SERVER_PORT=80
      - ADMIN_SERVER=demo.youoke.party
      - ADMIN_SERVER_PROXY=demo
      - ADMIN_SERVER_PORT=80
    volumes:
      - ./letsencrypt:/etc/letsencrypt
      - ./nginx.template:/etc/nginx/conf.d/nginx.template
    ports:
      - "80:80"
      - "443:443"
    command: /bin/bash -c "envsubst < /etc/nginx/conf.d/nginx.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
  helloworld: 
    image: 3dwardsharp/helloworld
  demo: 
    image: 3dwardsharp/helloworld

```

__nginx.template__

_note:_ do as your nginx-configuration-heart desires, just a simple example using `envsubst`: 

```
server {
  listen 80;
  server_name ${BASE_SERVER};
  
  include /etc/nginx/snippets/letsencrypt.conf;

  location / {
    return 301 https://${BASE_SERVER};
  }
}
server {
  listen 80;
  server_name ${ADMIN_SERVER};

  include /etc/nginx/snippets/letsencrypt.conf;

  location / {
    return 301 https://${ADMIN_SERVER};
  }
}

server {
  server_name ${BASE_SERVER};
  listen 443 ssl http2;

  ssl_certificate /etc/letsencrypt/live/${BASE_SERVER}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${BASE_SERVER}/privkey.pem;
  ssl_trusted_certificate /etc/letsencrypt/live/${BASE_SERVER}/fullchain.pem;
  include /etc/nginx/snippets/ssl.conf;

  location / {
    proxy_pass http://${BASE_SERVER_PROXY}:${BASE_SERVER_PORT};
    client_max_body_size 100m;
    proxy_buffering off;
  }
}
server {
  server_name ${ADMIN_SERVER};
  listen 443 ssl http2;

  ssl_certificate /etc/letsencrypt/live/${ADMIN_SERVER}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${ADMIN_SERVER}/privkey.pem;
  ssl_trusted_certificate /etc/letsencrypt/live/${ADMIN_SERVER}/fullchain.pem;
  include /etc/nginx/snippets/ssl.conf;

  location / {
    proxy_pass http://${ADMIN_SERVER_PROXY}:${ADMIN_SERVER_PORT};
    client_max_body_size 100m;
    proxy_buffering off;
  }
}
```