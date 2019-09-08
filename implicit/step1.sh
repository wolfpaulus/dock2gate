#!/bin/bash

AWS_PROFILE="edu"
AWS_REGION="us-west-2"
TASK_EXEC_ROLE="fargateTaskExecutionRoleV1"
CLUSTER_NAME="prime-cluster"

cd ./implicit
# Creating the Task-execution Role
RESULT=$(aws iam create-role --role-name $TASK_EXEC_ROLE --output json --region $AWS_REGION --profile $AWS_PROFILE --assume-role-policy-document file://task-execution-assume-role.json)
echo "[*] [$( date +'%H:%M:%S')] $RESULT"

# Attach the task execution role policy:
RESULT=$(aws iam attach-role-policy --role-name $TASK_EXEC_ROLE --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] 'AmazonECSTaskExecutionRolePolicy' attached to role: '$TASK_EXEC_ROLE'."

# Create an Amazon ECS empty cluster, implicitly also a VPC configured with two public subnets.
ecs-cli up --cluster $CLUSTER_NAME --launch-type FARGATE --region $AWS_REGION --aws-profile $AWS_PROFILE --force
