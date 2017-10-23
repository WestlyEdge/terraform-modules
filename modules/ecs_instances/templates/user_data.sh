#!/bin/bash

echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "BEGIN USER_DATA.SH"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# timezone
ln -fs /usr/share/zoneinfo/UTC /etc/localtime

# using script from http://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_cloudwatch_logs.html
# Install awslogs and the jq JSON parser
yum install -y awslogs jq aws-cli

# ECS config
${ecs_config}
{
  echo "ECS_CLUSTER=${cluster_name}"
  echo 'ECS_AVAILABLE_LOGGING_DRIVERS=${ecs_logging}'
} >> /etc/ecs/ecs.config

# inject the CloudWatch Logs configuration file contents
cat > /etc/awslogs/awslogs.conf <<- EOF
[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/dmesg]
file = /var/log/dmesg
log_group_name = ${cloudwatch_prefix}/var/log/dmesg
log_stream_name = ${cluster_name}/{container_instance_id}

[/var/log/messages]
file = /var/log/messages
log_group_name = ${cloudwatch_prefix}/var/log/messages
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %b %d %H:%M:%S

[/var/log/docker]
file = /var/log/docker
log_group_name = ${cloudwatch_prefix}/var/log/docker
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%S.%f

[/var/log/ecs/ecs-init.log]
file = /var/log/ecs/ecs-init.log.*
log_group_name = ${cloudwatch_prefix}/var/log/ecs/ecs-init.log
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/ecs-agent.log]
file = /var/log/ecs/ecs-agent.log.*
log_group_name = ${cloudwatch_prefix}/var/log/ecs/ecs-agent.log
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/audit.log]
file = /var/log/ecs/audit.log.*
log_group_name = ${cloudwatch_prefix}/var/log/ecs/audit.log
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/cloud-init-output.log]
file = /var/log/cloud-init-output.log
log_group_name = ${cloudwatch_prefix}/var/log/cloud-init-output
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/cloud-init.log]
file = /var/log/cloud-init.log
log_group_name = ${cloudwatch_prefix}/var/log/cloud-init
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

EOF

# set the region to send CloudWatch Logs data to (the region where the container instance is located)
region=$(curl 169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/.$//')
sed -i -e "s/region = us-east-1/region = $region/g" /etc/awslogs/awscli.conf

# set the ip address of the node
container_instance_id=$(curl 169.254.169.254/latest/meta-data/local-ipv4)
sed -i -e "s/{container_instance_id}/$container_instance_id/g" /etc/awslogs/awslogs.conf

cat > /etc/init/awslogjob.conf <<- EOF
#upstart-job
description "Configure and start CloudWatch Logs agent on Amazon ECS container instance"
author "Amazon Web Services"
start on started ecs

script
	exec 2>>/var/log/ecs/cloudwatch-logs-start.log
	set -x

	until curl -s http://localhost:51678/v1/metadata
	do
		sleep 1
	done

	service awslogs start
	chkconfig awslogs on
end script

EOF

# add the efs volume to the ecs host instance
yum install -y nfs-utils
mkdir /efs
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 fs-b5e8bcfc.efs.us-east-1.amazonaws.com:/ /efs
service docker restart

start ecs

# set a unique ec2 tag name for this instance
privateIp=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
privateIp=$(echo $privateIp | sed 's/\./_/g')
instanceId=$(curl http://169.254.169.254/latest/meta-data/instance-id)
azZone=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
name="${cluster_name}-host-$privateIp"
region=$${azZone::-1}

echo "instanceId: $instanceId"
echo "ec2Name: $name"
echo "region: $region"

aws ec2 create-tags --resources $instanceId --tags Key=Name,Value=$name --region $region

# apply custom userdata script code
${custom_userdata}

echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
echo "END USER_DATA.SH"
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
