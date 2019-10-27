The standard IRIS image from InterSystems has a long HEALTHCHECK period that will time out when we try to
start our composition.

The only thing this docker file does is to produce a new image that has a shorter HEALTHCHECK.

If you want to use a newer version of IRIS, run downloadiris.sh on the root of this Git repo to get the version of IRIS you want to run. Then configure the FROM clause on the Dockerfile of this image so it will use it.