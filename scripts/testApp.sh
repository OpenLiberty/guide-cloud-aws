#!/bin/bash
set -euxo pipefail

# Test app

mvn -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q clean package

docker pull icr.io/appcafe/open-liberty:kernel-java8-openj9-ubi

docker build -t system:1.0-SNAPSHOT system/.
docker build -t inventory:1.0-SNAPSHOT inventory/.

sed -i 's/\[inventory-repository-uri\]/inventory/g' kubernetes.yaml
sed -i 's/\[system-repository-uri\]/system/g' kubernetes.yaml

kubectl apply -f kubernetes.yaml

sleep 120

kubectl get pods

minikube ip

curl "http://$(minikube ip):31000/system/properties"
curl "http://$(minikube ip):32000/api/inventory/systems/system-service"

mvn failsafe:integration-test "-Dcluster.ip=$(minikube ip)"
mvn failsafe:verify

kubectl logs "$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep system)"
kubectl logs "$(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep inventory)"

# Clear .m2 cache
rm -rf ~/.m2
