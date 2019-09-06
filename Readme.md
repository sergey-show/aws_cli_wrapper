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
        ├── var
        │   └── myenv
        │       └── var.json
        ├── run.sh
        └── template
            ├── linked-role-es.yml
            └── stack-els.yml


> ./run.sh - this running script 
> ./var - this directory with var`s, every folder with name customer must include file json, in this file vars
> ./template - this directory include templates for staks aws (*in future plans creating any directory with groups stack, example ES AWS, EC2 AWS and more*)


*runing **sh ./run.sh** and input project name, before added vars in **json.file***

**in future dynamic create aws cli line command with any templates and parameters**


## How can use it

Running script ./run.sh

You can running this script in interactive mode or with key, if you want running interactive mode you must use ./run.sh i. For command line run use ./run.sh -v {your var directory} -p {your aws profile}

```bash
#with arguments
./run.sh -v myenv -p test
```
OR
```bash
#interactive mode
./run.sh i
```

Input your name profile of AWS credential, you can use this <a href="https://docs.aws.amazon.com/cli/latest/reference/configure/">link</a> for setup aws profile.

