FROM intersystemsdc/irisdemo-base-java:latest

LABEL maintainer="Amir Samary <amir.samary@intersystems.com>"

# Defaul Java options - You can override this when running the container
ENV JAVA_OPTS=-Xmx1024M

# Default configuration. Should be replaced on docker run or docker-compose.yml file
ENV INGESTION_THREADS_PER_WORKER=10
ENV DISABLE_JOURNAL_FOR_DROP_TABLE=false
ENV DISABLE_JOURNAL_FOR_TRUNCATE=false
ENV INGESTION_THREADS_PER_WORKER=15
ENV INGESTION_BATCH_SIZE=1000
ENV INGESTION_JDBC_URL=jdbc:IRIS://localhost:51774/USER
ENV INGESTION_JDBC_USERNAME=SuperUser
ENV INGESTION_JDBC_PASSWORD=sys
ENV CONSUMER_JDBC_URL=jdbc:IRIS://localhost:51774/USER
ENV CONSUMER_JDBC_USERNAME=SuperUser
ENV CONSUMER_JDBC_PASSWORD=sys
ENV CONSUMER_THREADS_PER_WORKER=10
ENV CONSUMER_TIME_BETWEEN_QUERIES_IN_MILLIS=0

ADD ./projects/app.jar /app/

HEALTHCHECK --interval=5s --timeout=3s \
  CMD curl -f http://localhost:8080/master/test || exit 1