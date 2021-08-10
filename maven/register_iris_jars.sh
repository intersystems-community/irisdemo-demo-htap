#!/bin/bash

mvn install:install-file -Dfile=./irislib/intersystems-jdbc-3.2.0.jar \
-DgroupId=com.intersystems \
-DartifactId=intersystems-jdbc \
-Dversion=3.2.0 \
-Dpackaging=jar \
-DcreateChecksum=true

mvn install:install-file -Dfile=./irislib/intersystems-xep-3.2.0.jar \
-DgroupId=com.intersystems \
-DartifactId=intersystems-xep \
-Dversion=3.2.0 \
-Dpackaging=jar \
-DcreateChecksum=true

mvn install:install-file -Dfile=./irislib/intersystems-utils-3.2.0.jar \
-DgroupId=com.intersystems \
-DartifactId=intersystems-utils \
-Dversion=3.2.0 \
-Dpackaging=jar \
-DcreateChecksum=true