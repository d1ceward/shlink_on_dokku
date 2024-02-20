#!/usr/bin/env sh
set -e

# regex function
parse_url() {
  eval $(echo "$1" | sed -e "s#^\(\(.*\)://\)\?\(\([^:@]*\)\(:\(.*\)\)\?@\)\?\([^/?]*\)\(/\(.*\)\)\?#${PREFIX:-URL_}SCHEME='\2' ${PREFIX:-URL_}USER='\4' ${PREFIX:-URL_}PASSWORD='\6' ${PREFIX:-URL_}HOSTPORT='\7' ${PREFIX:-URL_}DATABASE='\9'#")
}

# prefix variables to avoid conflicts and run parse url function on arg url
PREFIX="SHLINK_DB_" parse_url "$DATABASE_URL"

# Separate host and port
SHLINK_DB_HOST="$(echo $SHLINK_DB_HOSTPORT | sed -e 's,:.*,,g')"
SHLINK_DB_PORT="$(echo $SHLINK_DB_HOSTPORT | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')"

export DB_DRIVER=postgres
export DB_HOST=$SHLINK_DB_HOST
export DB_PORT=$SHLINK_DB_PORT
export DB_NAME=$SHLINK_DB_DATABASE
export DB_USER=$SHLINK_DB_USER
export DB_PASSWORD=$SHLINK_DB_PASSWORD

exec "$@"
