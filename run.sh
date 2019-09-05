#!/bin/bash

echo "Input your project name"
read project_dir

# Setup you account KEYS in aws cli 
echo "Input your AWS profile for ${project_dir}"
read CRED_USER

#Vars
WORK_DIR=$(pwd)
CUSTOMERS_DIR="${WORK_DIR}/customers"
PROFILE="--profile ${CRED_USER}"
AWS="aws ${PROFILE} cloudformation"
COMAND_CREATE="${AWS} create-stack"
VAR_FILE="${CUSTOMERS_DIR}/${project_dir}/var.json"
TMP_DIR="${CUSTOMERS_DIR}/tmp"
#AWS Parameters
export $(jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" ${VAR_FILE})
KEY="ParameterKey="
VALUE="ParameterValue="
TAGS="${KEY}Owner,${VALUE}${owner} ${KEY}Env,${VALUE}${env} ${KEY}Project,${VALUE}${project}"
S3BUCK="${KEY}S3,${VALUE}${s3bucket}"

# Create stacks ELK
${COMAND_CREATE} --stack-name ${owner}-es-linkedrole --template-body file://${WORK_DIR}/template/linked-role-es.yml
${AWS} wait stack-create-complete --stack-name ${owner}-es-linkedrole
${COMAND_CREATE} --stack-name ${stack}-s3 --capabilities CAPABILITY_IAM --template-body file://${WORK_DIR}/template/s3-bucket.yml --parameters ${TAGS} ${S3BUCK}
${AWS} ${PROFILE} wait stack-create-complete --stack-name ${stack}-s3 
aws ${PROFILE} s3 cp es-cleanup.zip s3://${s3bucket}-${project}/ 
${COMAND_CREATE} --stack-name ${stack}-es --capabilities CAPABILITY_IAM --template-body file://${WORK_DIR}/template/stack-els.yml --parameters ${KEY}DomainName,${VALUE}${domain} ${KEY}ExistingVPC,${VALUE}${vpc} ${KEY}Subnet,${VALUE}${subnet} ${TAGS} ${S3BUCK} ${KEY}EBSVolumeSize,${VALUE}${ebs_size}
${AWS} wait stack-create-complete --stack-name ${stack}-es