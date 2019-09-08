#!/bin/bash

AWS_PROFILE="edu"
AWS_REGION="us-west-2"
SECURITY_GRP_NAME="fargateSecurityGroupV1"
VPC_ID="vpc-013c500fc6f80ce02"

#Create a security Group
SECURITY_GRP_ID=$(aws ec2 create-security-group --group-name $SECURITY_GRP_NAME --description "Fargate Network access" --vpc-id $VPC_ID --query 'GroupId' --output text --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] '$SECURITY_GRP_NAME' Security Group with ID '$SECURITY_GRP_ID' created."
aws ec2 create-tags --resources $SECURITY_GRP_ID --tags Key=Name,Value="'$SECURITY_GRP_NAME'" --region $AWS_REGION --profile $AWS_PROFILE
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GRP_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $AWS_REGION --profile $AWS_PROFILE