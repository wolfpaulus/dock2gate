#!/bin/bash

AWS_PROFILE="edu"
AWS_REGION="us-west-2"
TASK_EXEC_ROLE="fargateTaskExecutionRoleV2"
CLUSTER_NAME="prime-cluster"
TG_NAME="prime-tg"
TG_PORT="80"
HEALTH_CHECK_PATH="/isPrime/17"

# Values from explicitly created or already existing VPC

VPC_ID="vpc-056..."
SUBNET_PRIVATE1_ID="subnet-07c4..."
SUBNET_PRIVATE2_ID="subnet-0296..."
SECURITY_GRP_ID="sg-0156..."
LOAD_BALANCER_NAME="prime-alb"

# Creating the Task-execution Role
RESULT=$(aws iam create-role --role-name $TASK_EXEC_ROLE --output json --region $AWS_REGION --profile $AWS_PROFILE --assume-role-policy-document file://task-execution-assume-role.json)
echo "[*] [$( date +'%H:%M:%S')] $RESULT"

# Attach the task execution role policy:
RESULT=$(aws iam attach-role-policy --role-name $TASK_EXEC_ROLE --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] 'AmazonECSTaskExecutionRolePolicy' attached to role: '$TASK_EXEC_ROLE'."

# Create an ECS cluster
echo "[*] [$( date +'%H:%M:%S')] Bring up ECS cluster..."
ecs-cli up --security-group $SECURITY_GRP_ID --subnets "'$SUBNET_PRIVATE1_ID','$SUBNET_PRIVATE2_ID'" --vpc $VPC_ID --launch-type FARGATE --cluster $CLUSTER_NAME --region $AWS_REGION  --aws-profile $AWS_PROFILE --force

# Target Group
TG_ARN=$(aws elbv2 create-target-group --name $TG_NAME --protocol HTTP --port $TG_PORT --target-type ip --health-check-path $HEALTH_CHECK_PATH --vpc-id $VPC_ID --query "TargetGroups[?TargetGroupName == '$TG_NAME'].TargetGroupArn" --output text --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] 'Target Group created'$TG_ARN'"

# Create Listener
LOAD_BALANCER_ARN=$(aws elbv2 describe-load-balancers --names $LOAD_BALANCER_NAME --query "LoadBalancers[0].LoadBalancerArn" --output text --region $AWS_REGION --profile $AWS_PROFILE)
LOAD_BALANCER_DNS_NAME=$(aws elbv2 describe-load-balancers --names $LOAD_BALANCER_NAME --query "LoadBalancers[0].DNSName" --output text --region $AWS_REGION --profile $AWS_PROFILE)

RESULT=$(aws elbv2 create-listener --load-balancer-arn $LOAD_BALANCER_ARN --protocol HTTP --port $TG_PORT --default-actions Type=forward,TargetGroupArn=$TG_ARN --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] 'Listener created. '$RESULT'"

# Launch ...
ecs-cli compose service up --create-log-groups --launch-type FARGATE --cluster $CLUSTER_NAME --target-group-arn $TG_ARN --container-name $CLUSTER_NAME --container-port $TG_PORT --region $AWS_REGION --aws-profile $AWS_PROFILE
ecs-cli ps --cluster $CLUSTER_NAME --region $AWS_REGION --aws-profile $AWS_PROFILE

# Test
RESULT=$(curl $LOAD_BALANCER_DNS_NAME$HEALTH_CHECK_PATH)
echo "[*] [$( date +'%H:%M:%S')] 'HTTP GET : '$RESULT'"

#
# Delete resources in this order
#
# ECS - Cluster Tasks - stop task
# ECS - delete task
# ECS - delete cluster
# CloudFormation delete stack
# Cloudwatch delete log group