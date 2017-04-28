#!/bin/bash
set -e

cert_tarball='/tmp/privateregistry_tls.tar.gz'
conf='/etc/docker/registry/config.yml'
gen_ssl_cert='/usr/local/bin/gen-ssl-cert'

# if there are entries specified in $REGISRY_AUTH_ENTRIES, drop them into
# the auth file
if [ ! -z "${PRIVATEREGISTRY_AUTH_ENTRIES}" ]; then
  echo ${PRIVATEREGISTRY_AUTH_ENTRIES} | base64 -d > ${REGISTRY_AUTH_HTPASSWD_PATH}
fi;

# create certs
cert_root=$(dirname ${REGISTRY_HTTP_TLS_KEY})
mkdir -p ${cert_root}

# if certs are passed in via environment, write them to disk
if [ ! -z "${PRIVATEREGISTRY_TLS}" ]; then
  echo ${PRIVATEREGISTRY_TLS} | base64 -d > ${cert_tarball}

  cd ${cert_root}
  tar xzf ${cert_tarball}
fi;

# otherwise, create certs if they don't exist
${gen_ssl_cert}

# drop configuration in
if [ ! -z "${PRIVATEREGISTRY_CONF}" ]; then
  mkdir -p $(dirname ${conf})

  echo ${PRIVATEREGISTRY_CONF} | base64 -d > ${conf}
fi;

exec /entrypoint.sh "$@"
