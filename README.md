# terraform-modules

To encourage re-usable infrastructure code, this repository contains Terraform modules that can be easily used by others.

This repo was created with ECS in mind... but creating one large module offers minimal value, therefore modules in this repo consist of other modules. This way it's easier for others to make changes, swap modules or use pieces from this repository even if not setting up a full highly available ECS host cluster.

Details regarding how a module works are described in the module itself (if needed).

## Conventions

These conventions exist in every module...

* Contains main.tf where all the terraform code is
* If main.tf is too big we create more *.tf files with proper names
* [Optional] Contains outputs.tf with the output parameters
* [Optional] Contains variables.tf which sets required attributes
* For grouping in AWS we set the tag "Environment" everywhere where possible

## ECS services

ECS services (such as Consul and Vault) are also packaged as re-usable modules @ */ecs_services/* 

## ECS Logs

All ECS instance logs are shipped out to Cloudwatch

## ECS configuration

ECS is configured using the */etc/ecs/ecs.config* file as you can see [here](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html). There are two important configurations in this file. One is the ECS cluster name so that it can connect to the cluster, this should be specified from terraform because you want this to be variable. The other one is access to Docker Hub to be able to access private repositories. To do this safely use an S3 bucket that contains the Docker Hub configuration. See the *ecs_config* variable in the *ecs_instances* module for an example.

## LoadBalancer

It is possible to use the Application LoadBalancer and the Classic LoadBalancer with this setup. The default configuration is Application LoadBalancer because that makes more sense in combination with ECS.

## ECS deployment strategies

ECS has a lot of different ways to deploy or place a task in the cluster. You can have different placement strategies like random and binpack, see here for full [documentation](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-placement-strategies.html). Besides the placement strategies, it is also possible to specify constraints, as described [here](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-placement-constraints.html). The constraints allow for a more fine-grained placement of tasks on specific EC2 nodes, like *instance type* or custom attributes.

## EC2 node security and updates

Because the EC2 nodes are created by us it means we need to make sure they are up to date and secure. It is possible to create an own AMI with your own OS, Docker, ECS agent and everything else. But it is much easier to use the [ECS optimized AMIs](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html) which are maintained by AWS with a secure AWS Linux, regular security patches, recommended versions of ECS agent, Docker and more...

To know when to update your EC2 node you can subscribe to AWS ECS AMI updates, like described [here](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS-AMI-SubscribeTopic.html).

If you need to perform an update you will need to update the information in the *ecs_instances* and then apply the changes on the cluster. This will only create a new *launch_configuration* but it will not touch the running instances. Therefore you need to replace your instances one by one. There are three ways to do this:

Terminating the instances, but this may cause disruption to your application users. By terminating an instance a new one will be started with the new *launch_configuration*

Double the size of your cluster and your applications and when everything is up and running scale the cluster down. This might be a costly operation and you also need to specify or protect the new instances so that the AWS auto scale does not terminate the new instances instead of the old ones.

The best option is to drain the containers from an ECS instance like described [here](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-instance-draining.html). Then you can terminate the instance without disrupting your application users. This can be done by doubling the EC2 nodes instances in your cluster or one by one. Currently, there is no automated/scripted way to do this.

## ECS detect deployments failure

When deploying manually we can see if the new container has started or is stuck in a start/stop loop. But when deploying automatically this is not visible. To make sure we get alerted when containers start failing we need to watch for events from ECS who state that a container has STOPPED. This can be done by using the module [ecs_events](modules/ecs_events/main.tf). The only thing that is missing from the module is the actual alert. This is because terraform can't handle email and all other protocols for *aws_sns_topic_subscription* are specific per customer.
