#!/usr/bin/env bash

service_name=prime_ws
tag_name=latest
repo_name=178522735890.dkr.ecr.us-west-2.amazonaws.com
img_name=tomcatprime

repo_uri=$repo_name/$service_name:$tag_name

gradle clean
gradle build
docker build -t $img_name .
docker tag $img_name:$tag_name $repo_uri
eval $(aws ecr get-login --no-include-email --region us-west-2 --profile edu)
docker push $repo_uri
