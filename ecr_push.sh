#!/usr/bin/env bash
#
# build, tag and push a docker image into AWS ecr
#
AWS_PROFILE="edu"
AWS_REGION="us-west-2"

SERVICE_NAME=prime_ws
TAG_NAME=latest
REPO_NAME=178522735890.dkr.ecr.us-west-2.amazonaws.com
IMG_NAME=tomcatprime

repo_uri=$REPO_NAME/$SERVICE_NAME:$TAG_NAME

gradle clean
gradle build
docker build -t $IMG_NAME .
docker tag $IMG_NAME:$TAG_NAME $repo_uri
eval $(aws ecr get-login --no-include-email --region $AWS_REGION --profile $AWS_PROFILE)
docker push $repo_uri
