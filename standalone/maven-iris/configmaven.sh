#!/bin/bash

mvn install:install-file -Dfile=./intersystems-jdbc-3.0.0.jar \
-DgroupId=com.intersystems \
-DartifactId=intersystems-jdbc \
-Dversion=3.0.0 \
-Dpackaging=jar \
-DcreateChecksum=true

mvn install:install-file -Dfile=./intersystems-xep-3.0.0.jar \
-DgroupId=com.intersystems \
-DartifactId=intersystems-xep \
-Dversion=3.0.0 \
-Dpackaging=jar \
-DcreateChecksum=true