#!/bin/bash

cls

docker run --name icm -it -v $PWD/ICMDurable:/ICMDurable --cap-add SYS_TIME docker.iscinternal.com/intersystems/icm:2019.4.0.383.0
Write-Host "`nExited icm container"
Write-Host "`nRemoving icm container...\nContainer removed: "
docker rm icm