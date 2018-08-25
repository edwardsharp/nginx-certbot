#!/bin/bash

certbot renew --noninteractive --renew-hook "nginx -s reload"
