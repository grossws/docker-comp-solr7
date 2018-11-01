#!/usr/bin/env bash

if [[ "$1" = "init" ]] ; then
  set -x
  [[ $# -gt 1 && ( "$2" = "-f" || "$2" = "--force" ) ]] && FORCE=1 || FORCE=0
  if [[ ! -d "/dest" ]] ; then
    echo "/dest should be mounted to initialize SOLR_HOME"
    exit 1
  elif [[ -n "$(ls -A /dest)" && ${FORCE} = "0" ]] ; then
    echo "Use '-f|--force' to initialize non-empty SOLR_HOME (mounted as /dest)"
    exit 1
  fi
  cp -r -f /solr/data/* /dest/
  exit 0
elif [[ "$1" = "solr" ]] ; then
  shift
  id -u solr &>/dev/null || useradd --system --no-create-home --no-user-group --gid nobody --uid ${SOLR_UID:-200} solr

  chown -R solr:nobody /solr/data/configsets/_default/conf /solr/data/core0/data /solr/data/logs
  export SOLR_LOGS_DIR=/solr/data/logs
  exec gosu solr:nobody /solr/bin/solr -f -h 0.0.0.0 -p 8983 -s /solr/data "$@"
elif [[ "$1" = "--help" || "$1" = "-h" || $# -eq 0 ]] ; then
  cat <<EOF
# With default configuration and schema (just external index and log directories)
docker run --name solr -p 8983:8983 \
  -v \`pwd\`/solr-data:/solr/data/core0/data \
  -v \`pwd\`/solr-logs:/solr/data/logs \
  grossws/solr7:latest [solr [-a '-Dsolr.extra.var=1 -Danother.var=xxx']]

# With external SOLR_HOME
## Initialization (once per SOLR_HOME):
docker run --rm -it -v \`pwd\`/solr-home:/dest grossws/solr7:latest init [--force|-f]
## Run with custom SOLR_HOME
docker run --name solr -p 8983:8983 \
  -v \`pwd\`/solr-home:/solr/data \
  -v \`pwd\`/solr-logs:/solr/data/logs \
  grossws/solr7:latest [solr [-a '-Dsolr.extra.var=1 -Danother.var=xxx']]

# Debug (JDWP)
docker run --name solr -p 8983:8983 -p 5005:5005 \
  grossws/solr7:latest solr -a '-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005'

# Help (this message)
docker run --rm grossws/solr7:latest --help|-h
EOF
  exit 0
fi

exec "$@"

