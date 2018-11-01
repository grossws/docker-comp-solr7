FROM grossws/java:latest AS dist

ARG SOLR_VERSION=7.5.0
RUN set -o errexit; set -o pipefail; source /root/.bash_helpers; \
  mkdir -p /solr; \
  gpg_rk $(gpg_parse_keys `apache_dist_url lucene/KEYS`); \
  SOLR_URL="lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz"; \
  echo "installing Apache Solr ${SOLR_VERSION}"; \
  dl_and_verify $(apache_dl_url ${SOLR_URL}) /solr.tgz $(apache_dist_url ${SOLR_URL}.asc); \
  tar xvf /solr.tgz --directory /solr --strip-components 1 \
    solr-${SOLR_VERSION}/bin/{oom_solr.sh,post,solr,solr.in.sh} \
    solr-${SOLR_VERSION}/{LICENSE.txt,NOTICE.txt,licenses} \
    solr-${SOLR_VERSION}/server/{contexts,etc,lib,modules,resources,solr-webapp,start.jar}; \
  rename .txt '' /solr/*.txt

RUN set -o errexit; set -o pipefail; source /root/.bash_helpers; \
  mkdir -p /solr/data/{configsets/_default/conf,core0/data,lib,logs}; \
  echo "<solr/>" > /solr/data/solr.xml; \
  echo -e "name = core0\nconfigSet = _default" > /solr/data/core0/core.properties
COPY default-conf/ /solr/data/configsets/_default/conf/

ARG GUAVA_VERSION=20.0
RUN set -o errexit; set -o pipefail; source /root/.bash_helpers; \
  WEBAPP_DIR=/solr/server/solr-webapp/webapp/WEB-INF/lib; \
  rm -f ${WEBAPP_DIR}/guava-*.jar; \
  curl --silent --show-error --location --output ${WEBAPP_DIR}/guava-${GUAVA_VERSION}.jar "https://search.maven.org/remotecontent?filepath=com/google/guava/guava/${GUAVA_VERSION}/guava-${GUAVA_VERSION}.jar"

RUN set -o errexit; set -o pipefail; source /root/.bash_helpers; \
  JETTY_VERSION=$(find /solr/server/lib -name 'jetty-server-*.jar' | sed 's|.jar$||; s|^.*/jetty-server-||;'); \
  echo "Eclipse Jetty version: ${JETTY_VERSION}"; \
  JETTY_SRC_BASE_URL="https://raw.githubusercontent.com/eclipse/jetty.project/jetty-${JETTY_VERSION}/jetty-server/src/main/config"; \
  curl --silent --show-error --location --output /solr/server/etc/jetty-gzip.xml ${JETTY_SRC_BASE_URL}/etc/jetty-gzip.xml; \
  curl --silent --show-error --location --output /solr/server/modules/gzip.mod ${JETTY_SRC_BASE_URL}/modules/gzip.mod; \
  sed --in-place --regexp-extended --expression 's|(SOLR_JETTY_CONFIG\+=\("--module=)(https?)("\))|\1\2,gzip\3|' /solr/bin/solr

ARG DVTF_VERSION=0.3.0
RUN set -o errexit; set -o pipefail; source /root/.bash_helpers; \
  curl --silent --show-error --location --output /solr/data/lib/solr-dvtf-${DVTF_VERSION}.jar https://github.com/grossws/solr-dvtf/releases/download/v${DVTF_VERSION}/solr-dvtf.jar

COPY entrypoint.sh /solr/


FROM grossws/java:latest

LABEL org.label-schema.name="Apache Solr 7.x on CentOS 7" \
  org.label-schema.vcs-url="https://github.com/grossws/docker-comp-solr7" \
  org.label-schema.docker.cmd="docker run --name solr -v `pwd`/solr-data:/solr/data/core0/data -v `pwd`/solr-logs:/solr/data/logs -p 8983:8983 grossws/solr7:latest" \
  org.label-schema.docker.cmd.debug="docker run --name solr -p 8983:8983 -p 5005:5005 grossws/solr7:latest solr -a '-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005'" \
  org.label-schema.docker.cmd.help="docker run --rm grossws/solr7:latest --help"

COPY --from=dist /solr /solr

VOLUME ["/solr/data"]
EXPOSE 8983

ENTRYPOINT ["/solr/entrypoint.sh"]
CMD ["solr"]

