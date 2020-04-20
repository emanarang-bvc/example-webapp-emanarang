#!/bin/bash
set -e
set -x

STACK_NAME=$1
ALB_LISTENER_ARN=$2

if ! aws cloudformation describe-stacks --region ca-central-1 --stack-name $STACK_NAME 2>&1 > /dev/null
then
	finished_check=stack-create-complete
else
	finished_check=stack-update-complete
fi

aws cloudformation deploy \
    --region ca-central-1 \
    --stack-name $STACK_NAME \
    --template-file service.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
    "DockerImage=687435209454.dkr.ecr.ca-central-1.amazonaws.com/example-webapp:$(git rev-parse HEAD)" \
	"VPC=vpc-ff5b1c97" \
	"Subnet=subnet-468cf92e" \
	"Cluster=default" \
	"Listener=$ALB_LISTENER_ARN"
	
aws cloudformation wait $finished_check --region ca-central-1 --stack-name $STACK_NAME