# terraform-modules

To encourage re-usable infrastructure code, this repository contains Terraform modules that can be easily used by others.

This repo was created with ECS in mind... but creating one large module offers minimal value, therefore modules in this repo consist of other modules. This way it's easier for others to make changes, swap modules or use pieces from this repository even if not setting up a full highly availabls ECS host cluster.

Details regarding how a module works is described in the module itself (if needed).

## Conventions

These conventions exist in every module...

* Contains main.tf where all the terraform code is
* If main.tf is too big we create more *.tf files with proper names
* [Optional] Contains outputs.tf with the output parameters
* [Optional] Contains variables.tf which sets required attributes
* For grouping in AWS we set the tag "Environment" everywhere where possible

## Module Structure

![Terraform module structure](img/ecs-terraform-modules.png)