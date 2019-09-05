# Basic Script for up stack with ES AWS

## Prepaire your machine

You need install **jq** package, for pharsing **json** file

> yum install jq -y
> apt install jq -y

and **aws cli** package, recomendation **pip**

> pip install awscli --upgrade --user
> pip install boto3

## Structure

        ./cloudformation/
        ├── Readme.md
        ├── customers
        │   └── myenv
        │       └── var.json
        ├── run.sh
        └── template
            ├── linked-role-es.yml
            └── stack-els.yml


> run.sh - this running script 
> ./customers - this directory with customers, every folder with name customer must include file json, in this file vars
> ./template - this directory include templates for staks aws (*in future plans creating any directory with groups stack, example ES AWS, EC2 AWS and more*)

temporary: before running ES stack you shoul create S3 bucket and upload es-cleanup.zip file, then used S3 name in parameter s3bucket

*runing **sh ./run.sh** and input project name, before added vars in **json.file***

**in future dynamic create aws cli line command with any templates and parameters**
