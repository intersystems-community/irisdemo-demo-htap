$ICM_TAG = Get-Content ./ICMDurable/CONF_ICM_TAG -First 1
$ICM_REPO = Get-Content ./ICMDurable/CONF_ICM_REPO -First 1

docker run --name icm --rm -it -v ${PWD}/ICMDurable:/ICMDurable --cap-add SYS_TIME ${ICM_REPO}:${ICM_TAG}

Write-Host "`nExited icm container"
Write-Host "`nRemoving icm container...\nContainer removed: "
