# terraform-modules

- Developed and tested with Terraform v0.10.4
- To encourage re-usable infrastructure code, this repository contains Terraform modules that can be easily used by others.
- This repo was created with ECS in mind... but creating one large module offers minimal value, therefore modules in this repo consist of other modules. This way it's easier for others to make changes, swap modules or use pieces from this repository even if not setting up a full highly available ECS host cluster.
- Details regarding how a module works are described in the module itself (if needed).

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

- All ECS instance logs are shipped out to a CloudWatch log group
- All ECS container service specific logs (such as Consul and Vault)are also shipped out to a CloudWatch log group