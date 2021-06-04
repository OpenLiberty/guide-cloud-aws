#!/bin/bash
while getopts t:d: flag;
do
    case "${flag}" in
        t) DATE="${OPTARG}";;
        d) DRIVER="${OPTARG}";;
    esac
done

echo "Testing latest OpenLiberty Docker image"

sed -i "\#<artifactId>liberty-maven-plugin</artifactId>#a<configuration><install><runtimeUrl>https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/nightly/"$DATE"/"$DRIVER"</runtimeUrl></install></configuration>" inventory/pom.xml system/pom.xml
cat inventory/pom.xml system/pom.xml

sed -i "s;FROM openliberty/open-liberty:kernel-java8-openj9-ubi;FROM openliberty/daily:latest;g" system/Dockerfile inventory/Dockerfile
cat system/Dockerfile inventory/Dockerfile

docker pull "openliberty/daily:latest"

../scripts/startMinikube.sh
../scripts/testApp.sh
../scripts/stopMinikube.sh
