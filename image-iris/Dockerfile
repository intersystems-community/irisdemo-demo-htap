ARG IRIS_STANDARD_IMAGE

FROM ${IRIS_STANDARD_IMAGE}
LABEL maintainer="Amir Samary <amir.samary@intersystems.com>"

HEALTHCHECK --interval=5s CMD /irisHealth.sh || exit 1