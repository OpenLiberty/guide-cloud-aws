#!/bin/bash
set -euxo pipefail

##############################################################################
##
##  Travis CI test script
##
##############################################################################

mvn -q clean package

cd inventory
mvn -q clean package liberty:create liberty:install-feature liberty:deploy
mvn liberty:start

sed -i 's/\[inventory-repository-uri\]/inventory/g' kubernetes.yaml
sed -i 's/\[system-repository-uri\]/system/g' kubernetes.yaml

cd ../system
mvn -q clean package liberty:create liberty:install-feature liberty:deploy
mvn liberty:start

cd ..

sleep 120

curl http://localhost:9080/system/properties
curl http://localhost:9081/inventory/systems/

mvn failsafe:integration-test -Dsystem.ip="localhost" -Dinventory.ip="localhost"

cd inventory
mvn liberty:stop

cd ../system
mvn liberty:stop
