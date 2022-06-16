#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"

decorator () {
    echo -e "Generating Task List: \n"
    echo -ne '[....................](00%)\r'
    sleep 1
    echo -ne '[#####...............](25%)\r'
    sleep 1
    echo -ne '[##########..........](50%)\r'
    sleep 1
    echo -ne '[###############.....](75%)\r'
    sleep 1
    echo -ne '[####################](100%)\r'
    echo -e '\n'
}

generate_task_list () {
    TASK_LIST=$(aws ecs list-tasks --cluster demo-cluster --family demo_flask_app --region us-east-1 | jq -r '.taskArns' | jq -r '.[]' | awk -F "/" '{print $3}')
    array=(${TASK_LIST/// })
    echo "Task ID List:"
    echo ""
    for i in "${!array[@]}"
        do
            echo "Task ID $i = ${array[i]}"
        done
}

PS3='Are you using a Profile? (Select an option): '
OPTIONS=("Yes" "No" "Quit")
select opt in "${OPTIONS[@]}"
do
	case $opt in
		"Yes")
            read -p "Input your AWS Profile Name: " AWS_PROFILE
            read -p "Input your AWS Region: " AWS_REGION
            read -p "Input the ECS Cluster Name: " ECS_CLUSTER
            read -p "Input the Container Name: " CONTAINER_NAME
            decorator; generate_task_list
            echo -e '\n'
            read -p "Input your Task ID (Copy and paste one of the above): " TASK_ID
            echo -e '\n'
            echo -e "[${BLUE}INFO${ENDCOLOR}] Using variales: $AWS_PROFILE $AWS_REGION $ECS_CLUSTER $CONTAINER_NAME $TASK_ID"
			aws ecs execute-command --cluster $ECS_CLUSTER --task $TASK_ID --container $CONTAINER_NAME --command "/bin/bash" --interactive --region $AWS_REGION --profile $AWS_PROFILE
			exit 0
			;;
		"No")
            read -p "Input your AWS Region: " AWS_REGION
            read -p "Input the ECS Cluster Name: " ECS_CLUSTER
            read -p "Input the Container Name: " CONTAINER_NAME
            decorator; generate_task_list
            echo -e '\n'
            read -p "Input your Task ID (Copy and paste one of the above): " TASK_ID
            echo -e '\n'
            echo -e "[${BLUE}INFO${ENDCOLOR}] Using variales: $AWS_REGION $ECS_CLUSTER $CONTAINER_NAME $TASK_ID"
			aws ecs execute-command --cluster $ECS_CLUSTER --task $TASK_ID --container $CONTAINER_NAME --command "/bin/bash" --interactive --region $AWS_REGION
			exit 0
			;;
		"Quit")
			echo -e "[${BLUE}INFO${ENDCOLOR}] Script ended"
			break
			;;
		*)
			echo -e "[${RED}ERROR${ENDCOLOR}] $REPLY Is an invalid option - Select the option NUMBER, for example: 1"
			exit 1
			;;
	esac
done