$IRIS_TAG = Get-Content ./ICMDurable/CONF_IRISVERSION -Raw
$IRIS_PRIVATE_REPO = Get-Content ./ICMDurable/CONF_DOCKERHUB_REPOSITORY -Raw

cls

docker run --name icm --rm -it -v $PWD\ICMDurable:/ICMDurable --cap-add SYS_TIME $IRIS_PRIVATE_REPO:icm.$IRIS_TAG

Write-Host "`nExited icm container"
Write-Host "`nRemoving icm container...\nContainer removed: "
