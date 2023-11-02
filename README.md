# JOMACS-Terraform-Project

# Author: Ayetor Gabriel Seyram Kofi

# Date: 31st October, 2023

# PURPOSE OF REPO

This repository was set up in fulfilment of a JOMACS IT TERRAFORM PROJECT. 

# *The objectives of the project are as follows:*

“Create a secure VPC environment in AWS using Terraform where an EC2 instance is running an Nginx web server. The EC2 instance should reside within a private subnet and should be accessible to the outside world via a load balancer. Traffic to the EC2 instance should be routed through a NAT gateway.”

# **Fulfilling the task:**

In line with the above objectives, terraform codes have been developed in two main directories, VPC and EC2, as seen in the repository.

# **VPC directory**

The VPC directory contains six (6) terraform files, namely:

	vpc.tf 

	variables.tf

	output.tf

	provider.tf

	store.tf

	locals.tf


With these files, the following resources were created: 

	1 aws vpc

	3 aws subnets (1 private subnet, 2 public subnets; the private subnet and 1 public subnet were created in 1 availability zone, whiles the other public subnet was in a different availability zone in the same region)

	2 aws route tables (1 public, 1 private)

	3 aws route table associations (2 public subnets were associated with the public route table, 1 private subnet was associated with the private route table) 

	1 internet gateway

	1 elastic IP for nat gateway 

	1 nat gateway

	2 routes (1 for internet gateway and public route table, and the other for nat gateway and the private route table)

	2 aws ssm parameter (1 for vpc id and 1 for subnets ids)


The main resource configurations were in vpc.tf file. 

Variables were defined in variable.tf file for:

•	aws region

•	vpc cidr

•	vpc name

•	subnet cidr

•	subnet names

•	eip for nat gateway and 

•	availability zones

The variables were carefully chosen to ensure reusability since these particular attributes could change from project to project. 

Outputs were defined for vpc id and subnets ids in the output.tf file and marked as “sensitive = true” to avoid being displayed on the terminal upon being created.

The providers, being aws and terraform, were declared in the provider.tf file, with a terraform version constraint on version 5.17.0 ("~> 5.17.0"). An s3 bucket was used as the backend for the terraform configuration, this was also declared in the provider.tf file, with a bucket name and key. Hence, the backend was not local.

“aws ssm parameter” was created to store vpc id and subnets ids in the stores.tf file with a local ssm path prefix passed from a local.tf file.

# **EC2 directory**

The EC2 directory is made up of:

	ec2.tf

	variables.tf

	output.tf

	provider.tf

	user_data.sh

	store.tf

	local.tf

	user_data1.sh

These files were used to create:

	3 security groups (1 for private ec2 instance, 1 for load balancer, 1 for a probable public ec2 instance)

	1 ec2 instance

	1 aws load balancer

	1 aws listener

	1 aws load balancer target group

	1 aws load balancer attachment

The resources outlined above, in EC2 directory, had main configurations in a ec2.tf file. 

Values for vpc id, and subnets ids were passed from the aforementioned aws ssm parameter resource that comes under VPC directory. A data “aws_ssm_parameter”  was thus created in a store.tf to pick the ids. ‘ssm_path_prefix” was employed here as well, in local.tf file.

Variables were declared in variables.tf for:

•	aws region

•	web port

•	web protocol

•	instance type

•	instance name

•	key name

•	ssh port

•	ssh IP

•	load balancer type 

•	instance ami and

•	load balancer listener forward type 

Again, the variables were carefully chosen to ensure reusability, hence only attributes that are changeable from project to project were declared in variables.

The private security group created had ingress for port “80” and references the security group of the load balancer in order to allow traffic to be routed to the private ec2 through the nat gateway. It as well references the public security group, due to reasons explained later on.

The load balancer created was an application load balancer, with a listener on port “80” and target group port also being “80”. The load balancer was associated with the two public subnets which were in different availability zones, as a load balancer must be in not less than two different availability zones. This informed the creation of two public subnets. 

Outputs were configured for load balancer dns name and private ec2 instance private id, in the output.tf file.

The providers, being aws and terraform, were declared in the provider.tf file. An s3 bucket was used as the backend for the terraform configuration, this was also declared in the provider.tf file. Hence, the backend for this directory’s (EC2) configuration was as well not local, but had a different key from the VPC directory.

A bash script named user_data.sh was used to bootstrap installation of nginx (and a reverse proxy) the changing of ssh port from 22 to 212 (sed -i "s/#Port 22/Port 212/" /etc/ssh/sshd_config) and the echoing of “JOMACS TERRAFORM PROJECTS” into “/var/www/html/index.html” file.

# **How to deploy the infrastructure**

To deploy the infrastructure:

	An aws s3 bucket must first be created, as the backend of the configuration would be passed to s3. In this project, the s3 bucket created was “jomacs-terraform-projects”. Different keys were provided for VPC(layer1) and EC2(layer2) directories. 

	cd into VPC directory, run terraform fmt, terraform init, terraform plan, terraform validate and terraform apply. This would create the 16 resources under the VPC directory, including the aws ssm parameter for vpc id and subnets ids as depicted in the picture below. 

![Screenshot (881)](https://github.com/seyramgabriel/JOMACS-Terraform-Project/assets/130064282/e0b0b40d-45b9-4c4c-a07b-69a629b033b6)

	cd into the EC2  directory, which has vpc id and subnet ids passed from aws parameter store using the “data aws ssm parameter “. Run terraform fmt, terraform init, terraform plan, terraform validate and terraform apply. This would create the following resources that are displayed upon running terraform state list.

![Screenshot (878)](https://github.com/seyramgabriel/JOMACS-Terraform-Project/assets/130064282/4f5c7f19-0a9f-4aad-b584-3a0c6008dd24)

In all, Twenty-six (26) resources, would be created. The load balancer dns name would be outputted on the terminal, as was declared in the output.tf file.

# **Assumptions made**

It was assumed that the private ec2 instance would need to be accessed via ssh, hence a security group was created for a public ec2 instance. The public security group had a port 212 as its ssh port and that could be accessed only by “my IP”. The public security group was referenced in the private security group (for the private instance) to allow access to the private instance from the public instance, as a bastion host. The private security group ssh port was also 212.  The ssh port was switched from 22 to 212 via user_data.tf to enhance security. The private IP of the private instance was declared for output in the output.tf file.

Even though the configuration for public instance has been commented out in the ec2.tf file, it is assumed that the need to ssh into the private instance would arise, which would occasion the creation of a public instance. The public instance configuration uses the public security group and references user_data1.tf for booth strapping to change the ssh port from 22 to 212. 

The assumption of ssh also informed the inclusion of keypair in the instance configuration.

# **Steps to validate the setup** 

To access the nginx page via the load balancer, a default html file was created for booth strapping in user_data. This file had “JOMACS TERRAFORM PROJECT” echoed into it to be displayed through a web browser. 

The private ec2 instance was created without public IP and was placed in the private route table (not having internet gateway, but rather nat gateway). 

HTTP traffic request to the private ec2 instance, is to be routed through the load balancer, then through the nat gateway.  A successful configuration and deployment would be validated if “JOMACS TERRAFORM PROJECTS” is displayed upon copying and pasting the outputed dns name of the load balancer in a web browser, as demonstrated in the following two pictures.

*copying the load balancer dns name:*
![Screenshot (884)](https://github.com/seyramgabriel/JOMACS-Terraform-Project/assets/130064282/0aea55cd-d813-40b6-b627-691afedff895)


*pasting in a web browser:*
![Screenshot (885)](https://github.com/seyramgabriel/JOMACS-Terraform-Project/assets/130064282/0581fce4-2d6a-4219-90e0-ec1ca79aa969)


# AWS Architecture of the Project:


![Screenshot (883)](https://github.com/seyramgabriel/JOMACS-Terraform-Project/assets/130064282/688ac5a9-5100-48fa-8cb0-03d5fca21baa)


# *CI/CD*

A github workflow has been created in the .github/workflow directory to automate the running of this terraform configuration upon successive updates in the repository, specifically in the directories that have terraform configuration files (VPC and EC2). There are two yaml files, actions.yaml and actions1.yaml. The actions.yaml file contains codes that create a workflow for the running of "terraform fmt, terraform init, terraform plan, and terraform apply" in VPC directory whenever there is a commit to either VPC or EC2 directories or both. The other yaml file, actions1.yaml specifies that upon the successfull running of action.yaml file terraform will run in EC2 directory as well. This means actions1.yaml is dependent on the completion of actions.yaml. 

*CI/CD Summary*

1. There are two yaml files (actions.yaml and actions1.yaml) that contain different workflows.
  
2. actions.yaml is triggered whenever there is a commit in either VPC directory, EC2 directory, or both. The workflow in actions.yaml is to run terraform in VPC directory.

3. actions1.yaml is triggered upon successful execution of actions.yaml and it runs terraform in EC2 directory.

4. The two yaml files ensure that the network configurations (that is aws vpc, subnets, internet gateway and nat gateway are always available) before instances and load balancers are provisioned within the network configurations.


# Conclusion
Notably, the deployment of the infrastructure is in two phases. The first phase provisions the network configuration of the architecture and the second phase provisions ec2 instance and load balancer with their accompanying security group and listeners.

Having git cloned the repository (git clone https://github.com/seyramgabriel/JOMACS-Terraform-Project.git) and following the steps to deploy the infrastructure, one would be able to get this same architecture provisioned on AWS.


