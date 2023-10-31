variable "region" {
  default = "us-east-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  default = "star_vpc"
}

variable "subnetnames" {
  default = ["private_sn1", "public_sn1", "public_sn2"]
  type    = list(any)
}

variable "subnet1_cidr" {
  default = "10.0.1.0/24"
}

variable "subnet2_cidr" {
  default = "10.0.2.0/24"
}

variable "subnet3_cidr" {
  default = "10.0.3.0/24"
}

variable "az" {
  default = ["us-east-2a", "us-east-2b"]
  type    = list(any)
}

variable "nat-gw-ip" {
  default = "10.0.0.5"
}