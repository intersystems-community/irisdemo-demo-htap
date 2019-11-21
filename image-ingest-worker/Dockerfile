ARG VERSION

FROM intersystemsdc/irisdemo-base-java:latest

LABEL maintainer="Amir Samary <amir.samary@intersystems.com>"

# Defaul Java options - You can override this when running the container
ENV JAVA_OPTS=-Xmx1024M

# Default configuration. Should be replaced on docker run or docker-compose.yml file
ENV MASTER_HOSTNAME=master
ENV MASTER_PORT=80

ADD ./projects/app.jar /app/

HEALTHCHECK --interval=5s --timeout=3s \
  CMD curl -f http://localhost:8080/worker/test || exit 1