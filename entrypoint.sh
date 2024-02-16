#!/usr/bin/env sh
set -e

# regex function
parse_url() {
  eval $(echo "$1" | sed -e "s#^\(\(.*\)://\)\?\(\([^:@]*\)\(:\(.*\)\)\?@\)\?\([^/?]*\)\(/\(.*\)\)\?#${PREFIX:-URL_}SCHEME='\2' ${PREFIX:-URL_}USER='\4' ${PREFIX:-URL_}PASSWORD='\6' ${PREFIX:-URL_}HOSTPORT='\7' ${PREFIX:-URL_}DATABASE='\9'#")
}

# prefix variables to avoid conflicts and run parse url function on arg url
PREFIX="SHLINK_DB_" parse_url "$DATABASE_URL"
echo "$SHLINK_DB_SCHEME://$SHLINK_DB_USER:$SHLINK_DB_PASSWORD@$SHLINK_DB_HOSTPORT/$SHLINK_DB_DATABASE"

# Separate host and port
SHLINK_DB_HOST="$(echo $SHLINK_DB_HOSTPORT | sed -e 's,:.*,,g')"
SHLINK_DB_PORT="$(echo $SHLINK_DB_HOSTPORT | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"

export DB_DRIVER=postgres
export DB_HOST=$SHLINK_DB_HOST
export DB_PORT=$SHLINK_DB_PORT
export DB_NAME=$SHLINK_DB_DATABASE
export DB_USER=$SHLINK_DB_USER
export DB_PASSWORD=$SHLINK_DB_PASSWORD

cd /etc/shlink

# Create data directories if they do not exist. This allows data dir to be mounted as an empty dir if needed
mkdir -p data/cache data/locks data/log data/proxies

flags="--no-interaction --clear-db-cache"

# Skip downloading GeoLite2 db file if the license key env var was not defined or skipping was explicitly set
if [ -z "${GEOLITE_LICENSE_KEY}" ] || [ "${SKIP_INITIAL_GEOLITE_DOWNLOAD}" = "true" ]; then
  flags="${flags} --skip-download-geolite"
fi

# If INITIAL_API_KEY was provided, create an initial API key
if [ -n "${INITIAL_API_KEY}" ]; then
  flags="${flags} --initial-api-key=${INITIAL_API_KEY}"
fi

php vendor/bin/shlink-installer init ${flags}

if [ "$SHLINK_RUNTIME" = 'rr' ]; then
  ./bin/rr serve -c config/roadrunner/.rr.yml
fi
