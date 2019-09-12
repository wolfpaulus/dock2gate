#!/bin/bash

AWS_PROFILE="edu"
AWS_REGION="us-west-2"
CLUSTER_NAME="prime-cluster"

ecs-cli compose service up --create-log-groups --launch-type FARGATE --cluster $CLUSTER_NAME --region $AWS_REGION --aws-profile $AWS_PROFILE
ecs-cli ps --cluster $CLUSTER_NAME --region $AWS_REGION --aws-profile $AWS_PROFILE

