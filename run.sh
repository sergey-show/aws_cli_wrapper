#!/bin/bash

command -v aws >/dev/null 2>&1 || {
    echo >&2 "Please install awscli."
    exit 1
}

usage()
{
cat << EOF
Usage: $0 [-v name of your var directory] [-p your aws credentials profile]

You can running with "interactive" mode

OPTIONS:
   -v name of your var directory;
   -p your aws credentials profile;
   -i interactive mode;

EOF
}

while getopts ":v:p:" OPTION; do
    case $OPTION in
        v)
            project_dir="$OPTARG"
        ;;
        p)
            CRED_USER="$OPTARG"
        ;;
        ?)
            echo "Error: Invalid option -$OPTARG" >&2
            usage
            exit 0
        ;;
    esac
done

if [ $1 = "i" ]; then 
echo "Input your project name"
read project_dir

# Setup you account KEYS in aws cli 
echo "Input your AWS profile for ${project_dir}"
read CRED_USER
fi

#Vars
WORK_DIR=$(pwd)
VAR_DIR="${WORK_DIR}/var"
PROFILE="--profile ${CRED_USER}"
AWS="echo aws ${PROFILE} cloudformation"
COMAND_CREATE="echo ${AWS} create-stack"
VAR_FILE="${VAR_DIR}/${project_dir}/var.json"
TMP_DIR="${VAR_DIR}/tmp"
#AWS Parameters
export $(jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" ${VAR_FILE})
KEY="ParameterKey="
VALUE="ParameterValue="
TAGS="${KEY}Owner,${VALUE}${owner} ${KEY}Env,${VALUE}${env} ${KEY}Project,${VALUE}${project}"
S3BUCK="${KEY}S3,${VALUE}${s3bucket}"

if [ -n "$project_dir" ] ; then 
# Create stacks ELK
${COMAND_CREATE} --stack-name ${owner}-es-linkedrole --template-body file://${WORK_DIR}/template/linked-role-es.yml
${AWS} wait stack-create-complete --stack-name ${owner}-es-linkedrole
${COMAND_CREATE} --stack-name ${stack}-s3 --capabilities CAPABILITY_IAM --template-body file://${WORK_DIR}/template/s3-bucket.yml --parameters ${TAGS} ${S3BUCK}
${AWS} ${PROFILE} wait stack-create-complete --stack-name ${stack}-s3 
echo aws ${PROFILE} s3 cp es-cleanup.zip s3://${s3bucket}-${project}/ 
${COMAND_CREATE} --stack-name ${stack}-es --capabilities CAPABILITY_IAM --template-body file://${WORK_DIR}/template/stack-els.yml --parameters ${KEY}DomainName,${VALUE}${domain} ${KEY}ExistingVPC,${VALUE}${vpc} ${KEY}Subnet,${VALUE}${subnet} ${TAGS} ${S3BUCK} ${KEY}EBSVolumeSize,${VALUE}${ebs_size}
${AWS} wait stack-create-complete --stack-name ${stack}-es
fi