source ../utils.sh

kubectl delete -f ../deployment-ui.yml
exit_if_error "Could not delete deployment-ui.yml"

kubectl delete -f ../deployment-master.yml
exit_if_error "Could not delete deployment-master.yml"

kubectl delete -f ../deployment-workers.yml
exit_if_error "Could not delete deployment-workers.yml"

kubectl delete -f ./storage-class-iris*.yml
exit_if_error "Could not delete storage-class.yml"

kubectl delete -f ../deployment-iris.yml
exit_if_error "Could not apply deployment-iris.yml"

kubectl delete svc/iris-svc
exit_if_error "Could not delete svc iris-svc"

kubectl delete pvc --all
exit_if_error "Could not delete pvc"

kubectl delete secret iris-key-secret
exit_if_error "Could not delete secret key"

helm delete intersystems
exit_if_error "Error with chart installation for iris kubernetes operator"

