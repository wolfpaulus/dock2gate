#!/bin/bash

AWS_PROFILE="edu"
AWS_REGION="us-west-2"
VPC_NAME="Fargate VPC"
VPC_CIDR="10.0.0.0/16"

SUBNET_PUBLIC1_CIDR="10.0.1.0/24"
SUBNET_PUBLIC1_AZ="us-west-2a"
SUBNET_PUBLIC1_NAME="10.0.1.0 - us-west-2a"

SUBNET_PUBLIC2_CIDR="10.0.2.0/24"
SUBNET_PUBLIC2_AZ="us-west-2b"
SUBNET_PUBLIC2_NAME="10.0.2.0 - us-west-2b"

SUBNET_PRIVATE1_CIDR="10.0.3.0/24"
SUBNET_PRIVATE1_AZ="us-west-2a"
SUBNET_PRIVATE1_NAME="10.0.3.0 - us-west-2a"

SUBNET_PRIVATE2_CIDR="10.0.4.0/24"
SUBNET_PRIVATE2_AZ="us-west-2b"
SUBNET_PRIVATE2_NAME="10.0.4.0 - us-west-2b"

SECURITY_GRP_NAME="fargateSecurityGroupV2"
LOAD_BALANCER_NAME="prime-alb"

# Create VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --query 'Vpc.{VpcId:VpcId}' --output text --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] VPC ID '$VPC_ID' CREATED in '$AWS_REGION' region."

# Add Name tag to VPC
aws ec2 create-tags --resources $VPC_ID --tags "Key=Name,Value=$VPC_NAME" --region $AWS_REGION --profile $AWS_PROFILE
echo "[*] [$( date +'%H:%M:%S')] VPC ID '$VPC_ID' NAMED as '$VPC_NAME'."

# Create Public Subnet 1
SUBNET_PUBLIC1_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_PUBLIC1_CIDR --availability-zone $SUBNET_PUBLIC1_AZ --query 'Subnet.{SubnetId:SubnetId}' --output text --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] Public Subnet ID '$SUBNET_PUBLIC1_ID' CREATED in '$SUBNET_PUBLIC1_AZ' Availability Zone."
# Add Name tag to Public Subnet 1
aws ec2 create-tags --resources $SUBNET_PUBLIC1_ID --tags "Key=Name,Value=$SUBNET_PUBLIC1_NAME" --region $AWS_REGION --profile $AWS_PROFILE
echo "[*] [$( date +'%H:%M:%S')] Public Subnet ID '$SUBNET_PUBLIC1_ID' NAMED as '$SUBNET_PUBLIC1_NAME'."

# Create Public Subnet 2
SUBNET_PUBLIC2_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_PUBLIC2_CIDR --availability-zone $SUBNET_PUBLIC2_AZ --query 'Subnet.{SubnetId:SubnetId}' --output text --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] Public Subnet ID '$SUBNET_PUBLIC2_ID' CREATED in '$SUBNET_PUBLIC2_AZ' Availability Zone."
# Add Name tag to Public Subnet 1
aws ec2 create-tags --resources $SUBNET_PUBLIC2_ID --tags "Key=Name,Value=$SUBNET_PUBLIC2_NAME" --region $AWS_REGION --profile $AWS_PROFILE
echo "[*] [$( date +'%H:%M:%S')] Public Subnet ID '$SUBNET_PUBLIC2_ID' NAMED as '$SUBNET_PUBLIC2_NAME'."

# Create Private Subnet 1
SUBNET_PRIVATE1_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_PRIVATE1_CIDR --availability-zone $SUBNET_PRIVATE1_AZ --query 'Subnet.{SubnetId:SubnetId}' --output text --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] Private Subnet ID '$SUBNET_PRIVATE1_ID' CREATED in '$SUBNET_PRIVATE1_AZ' Availability Zone."
# Add Name tag to Private Subnet
aws ec2 create-tags --resources $SUBNET_PRIVATE1_ID --tags "Key=Name,Value=$SUBNET_PRIVATE1_NAME" --region $AWS_REGION --profile $AWS_PROFILE
echo "[*] [$( date +'%H:%M:%S')] Private Subnet ID '$SUBNET_PRIVATE1_ID' NAMED as '$SUBNET_PRIVATE1_NAME'."

# Create Private Subnet 2
SUBNET_PRIVATE2_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_PRIVATE2_CIDR --availability-zone $SUBNET_PRIVATE2_AZ --query 'Subnet.{SubnetId:SubnetId}' --output text --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] Private Subnet ID '$SUBNET_PRIVATE2_ID' CREATED in '$SUBNET_PRIVATE2_AZ' Availability Zone."
# Add Name tag to Private Subnet
aws ec2 create-tags --resources $SUBNET_PRIVATE2_ID --tags "Key=Name,Value=$SUBNET_PRIVATE2_NAME" --region $AWS_REGION --profile $AWS_PROFILE
echo "[*] [$( date +'%H:%M:%S')] Private Subnet ID '$SUBNET_PRIVATE2_ID' NAMED as '$SUBNET_PRIVATE2_NAME'."

# Create Internet gateway
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.{InternetGatewayId:InternetGatewayId}' --output text --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] Internet Gateway ID '$IGW_ID' CREATED."

# Attach Internet gateway to your VPC
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID --region $AWS_REGION --profile $AWS_PROFILE
echo "[*] [$( date +'%H:%M:%S')] Internet Gateway ID '$IGW_ID' ATTACHED to VPC ID '$VPC_ID'."

# Create Route Table
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.{RouteTableId:RouteTableId}' --output text --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] Route Table ID '$ROUTE_TABLE_ID' CREATED."

# Create route to Internet Gateway
RESULT=$(aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] Route to '0.0.0.0/0' via Internet Gateway ID '$IGW_ID' ADDED to Route Table ID '$ROUTE_TABLE_ID'."

# Associate Public Subnet with Route Table
RESULT=$(aws ec2 associate-route-table  --subnet-id $SUBNET_PUBLIC1_ID --route-table-id $ROUTE_TABLE_ID --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] Public Subnet ID '$SUBNET_PUBLIC1_ID' ASSOCIATED with Route Table ID '$ROUTE_TABLE_ID'."
RESULT=$(aws ec2 associate-route-table  --subnet-id $SUBNET_PUBLIC2_ID --route-table-id $ROUTE_TABLE_ID --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] Public Subnet ID '$SUBNET_PUBLIC2_ID' ASSOCIATED with Route Table ID '$ROUTE_TABLE_ID'."

# Associate Private Subnet with Route Table
#RESULT=$(aws ec2 associate-route-table  --subnet-id $SUBNET_PRIVATE1_ID --route-table-id $ROUTE_TABLE_ID --region $AWS_REGION --profile $AWS_PROFILE)
#echo "[*] [$( date +'%H:%M:%S')] Private Subnet ID '$SUBNET_PRIVATE1_ID' ASSOCIATED with Route Table ID '$ROUTE_TABLE_ID'."

# Associate Private Subnet with Route Table
#RESULT=$(aws ec2 associate-route-table  --subnet-id $SUBNET_PRIVATE2_ID --route-table-id $ROUTE_TABLE_ID --region $AWS_REGION --profile $AWS_PROFILE)
#echo "[*] [$( date +'%H:%M:%S')] Private Subnet ID '$SUBNET_PRIVATE2_ID' ASSOCIATED with Route Table ID '$ROUTE_TABLE_ID'."

# Enable Auto-assign Public IP on Public Subnets
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_PUBLIC1_ID --map-public-ip-on-launch --region $AWS_REGION --profile $AWS_PROFILE
echo "[*] [$( date +'%H:%M:%S')] Auto-assign Public IP ENABLED on Public Subnet ID '$SUBNET_PUBLIC1_ID'."
aws ec2 modify-subnet-attribute --subnet-id $SUBNET_PUBLIC2_ID --map-public-ip-on-launch --region $AWS_REGION --profile $AWS_PROFILE
echo "[*] [$( date +'%H:%M:%S')] Auto-assign Public IP ENABLED on Public Subnet ID '$SUBNET_PUBLIC2_ID'."

# Allocate Elastic IP Address for NAT Gateway
EIP_ALLOC_ID=$(aws ec2 allocate-address --domain vpc --query '{AllocationId:AllocationId}' --output text --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] Elastic IP address ID '$EIP_ALLOC_ID' ALLOCATED."

# Create NAT Gateway
NAT_GW_ID=$(aws ec2 create-nat-gateway --subnet-id $SUBNET_PUBLIC1_ID --allocation-id $EIP_ALLOC_ID --query 'NatGateway.{NatGatewayId:NatGatewayId}' --output text --region $AWS_REGION --profile $AWS_PROFILE)
printf "Creating NAT Gateway ID '$NAT_GW_ID' and waiting for it to become available.\n "
CHECK_FREQUENCY=5
SECONDS=0
LAST_CHECK=0
STATE='PENDING'
until [[ $STATE == 'AVAILABLE' ]]; do
  INTERVAL=$SECONDS-$LAST_CHECK
  if [[ $INTERVAL -ge $CHECK_FREQUENCY ]]; then
    STATE=$(aws ec2 describe-nat-gateways --nat-gateway-ids $NAT_GW_ID --query 'NatGateways[*].{State:State}' --output text --region $AWS_REGION --profile $AWS_PROFILE)
    STATE=$(echo $STATE | tr '[:lower:]' '[:upper:]')
    LAST_CHECK=$SECONDS
  fi
  SECS=$SECONDS
  STATUS_MSG=$(printf "$FORMATTED_MSG" \
    $STATE $(($SECS/3600)) $(($SECS%3600/60)) $(($SECS%60)))
  printf "    $STATUS_MSG\033[0K\r"
  sleep 1
done
printf "\n"
echo "[*] [$( date +'%H:%M:%S')] NAT Gateway ID '$NAT_GW_ID' is now AVAILABLE."

# Create route to NAT Gateway
MAIN_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$VPC_ID Name=association.main,Values=true --query 'RouteTables[*].{RouteTableId:RouteTableId}' --output text --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] Main Route Table ID is '$MAIN_ROUTE_TABLE_ID'."

RESULT=$(aws ec2 create-route --route-table-id $MAIN_ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $NAT_GW_ID --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] Route to '0.0.0.0/0' via NAT Gateway with ID '$NAT_GW_ID' ADDED to Route Table ID '$MAIN_ROUTE_TABLE_ID'."

#Create a security Group
SECURITY_GRP_ID=$(aws ec2 create-security-group --group-name $SECURITY_GRP_NAME --description "Fargate Network access" --vpc-id $VPC_ID --query 'GroupId' --output text --region $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S')] '$SECURITY_GRP_NAME' Security Group with ID '$SECURITY_GRP_ID' created."
aws ec2 create-tags --resources $SECURITY_GRP_ID --tags Key=Name,Value="'$SECURITY_GRP_NAME'" --region $AWS_REGION --profile $AWS_PROFILE

# authorize traffic from same security group (registering ecs)
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GRP_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $AWS_REGION --profile $AWS_PROFILE
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GRP_ID --protocol tcp --port 443 --cidr 0.0.0.0/0 --region $AWS_REGION --profile $AWS_PROFILE

# ALB
ALB_RESPONSE=$(aws elbv2 create-load-balancer --name $LOAD_BALANCER_NAME --subnets $SUBNET_PUBLIC1_ID $SUBNET_PUBLIC2_ID --security-groups $SECURITY_GRP_ID --region  $AWS_REGION --profile $AWS_PROFILE)
echo "[*] [$( date +'%H:%M:%S') '$ALB_RESPONSE']"


# Delete resources in this order
#
# VPC  -Nat Gateway (wait until deleted)
# EC2 - LOAD_BALANCER
# VPC - Delete VPC
# VPC - Delete DHCP
# VPC - Release IP
# IAM - Delete role
