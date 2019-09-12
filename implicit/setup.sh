#!/bin/bash

AWS_PROFILE="edu"
AWS_REGION="us-west-2"
TASK_EXEC_ROLE="fargateTaskExecutionRoleV1"
SECURITY_GRP_NAME="fargateSecurityGroupV1"
CLUSTER_NAME="prime-cluster"

# Creating the Task-execution Role
RESULT=$(aws iam create-role --role-name $TASK_EXEC_ROLE --output json --region $AWS_REGION --profile $AWS_PROFILE --assume-role-policy-document file://task-execution-assume-role.json)
echo "[*] [$( date +'%H:%M:%S')] $RESULT"

# Attach the task execution role policy:
RESULT=$(aws iam attach-role-policy --role-name $TASK_EXEC_ROLE --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] 'AmazonECSTaskExecutionRolePolicy' attached to role: '$TASK_EXEC_ROLE'."

# Create an Amazon ECS empty cluster, implicitly also a VPC configured with two public subnets.
ecs-cli up --cluster $CLUSTER_NAME --launch-type FARGATE --region $AWS_REGION --aws-profile $AWS_PROFILE --force

VPC_ID=$(aws ec2 describe-vpcs --region $AWS_REGION --profile $AWS_PROFILE --query "Vpcs[?Tags[?Key=='aws:cloudformation:stack-name']].VpcId" --output text)
echo "[*] [$( date +'%H:%M:%S')] VPC created with VpcId: '$VPC_ID'."

#Create a security Group
SECURITY_GRP_ID=$(aws ec2 create-security-group --group-name $SECURITY_GRP_NAME --description "Fargate Network access" --vpc-id $VPC_ID --query 'GroupId' --output text --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] '$SECURITY_GRP_NAME' Security Group with ID '$SECURITY_GRP_ID' created."
aws ec2 create-tags --resources $SECURITY_GRP_ID --tags Key=Name,Value="'$SECURITY_GRP_NAME'" --region $AWS_REGION --profile $AWS_PROFILE
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GRP_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $AWS_REGION --profile $AWS_PROFILE