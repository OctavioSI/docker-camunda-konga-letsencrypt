FROM camunda/camunda-bpm-platform:${DISTRO:-latest}

COPY ./camunda-config/bpm-platform.xml /camunda/conf/bpm-platform.xml
COPY ./camunda-config/logging.properties /camunda/conf/logging.properties
