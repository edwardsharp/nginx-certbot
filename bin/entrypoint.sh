#!/bin/bash

set -e

# validate env varz.
[[ -z "$DOMAINS" ]] && MISSING="$MISSING DOMAINS"
[[ -z "$EMAIL" ]] && MISSING="$MISSING EMAIL"
if [[ -n "$MISSING" ]]; then
	echo "Missing required environment variables: $MISSING" >&2
	exit 1
fi

# certificatez are separated by semi-colon (;). sub-domainz on each certificate are
# separated by comma (,).
CERTS=(${DOMAINS//;/ })

# dry-run certbot first, if exit is ok (0) then omit --dry-run
for DOMAINS in "${CERTS[@]}"; do
	SUBDOMAINS=(${DOMAINS//,/ })
	for DOMAIN in "${SUBDOMAINS[@]}"; do
		# check if certz for $DOMAIN exist
  	# "/etc/letsencrypt/live/${DOMAIN}/privkey.pem"
  	if [ ! -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    	echo "running certbot for ${DOMAIN}"
	  	certbot certonly \
				--agree-tos \
				-d "$DOMAIN" \
				--email "$EMAIL" \
				--expand \
				--noninteractive \
				--standalone \
				--preferred-challenges http \
				--dry-run \
				$OPTIONS
				|| EXITSTATUS=$? && true ; 

			if [ $EXITSTATUS -eq 0 ]; then
				echo "dry run success! fetching cert for $DOMAINS"
				certbot certonly \
					--agree-tos \
					-d "$DOMAIN" \
					--email "$EMAIL" \
					--expand \
					--noninteractive \
					--standalone \
					--preferred-challenges http \
					$OPTIONS 
			fi
		fi
	done
done

crond

exec "$@"
