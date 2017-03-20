FROM openjdk:8-jre-alpine

ENV SONATYPE_WORK /sonatype-work
ENV IQ_VERSION 1.26.0-01

RUN apk add --no-cache curl && \
    mkdir -p /opt/sonatype/iq-server && \
    curl --fail --silent --location --retry 3 \
    https://download.sonatype.com/clm/server/nexus-iq-server-${IQ_VERSION}-bundle.tar.gz \
  | gunzip\
  | tar x -C /opt/sonatype/iq-server nexus-iq-server-${IQ_VERSION}.jar config.yml

VOLUME ${SONATYPE_WORK}

ENV JVM_OPTIONS -server
EXPOSE 8070
EXPOSE 8071
WORKDIR /opt/sonatype/iq-server

CMD ${JAVA_HOME}/bin/java \
  ${JVM_OPTIONS} \
  -Ddw.sonatypeWork=${SONATYPE_WORK} \
  -jar nexus-iq-server-${IQ_VERSION}.jar \
  server config.yml
