variable "region" {
  default = "us-east-2"
}

variable "web_port" {
  default = 80
  type    = number
}

variable "web_protocol" {
  default = "HTTP"
}

/*variable "remote_state_bucket" {
  default     = "jomacs-terraform-projects"
  description = "Bucket name for layer 2 remote state"
}

variable "remote_state_key" {
  default     = "layer2/terraform.tfstate"
  description = "Key name for layer 2 remote state"
}*/

variable "instance_type" {
  default = "t2.micro"
}

variable "instance_name" {
  default = "EC2_NGINX"
}

/*variable "key" {
  default = file("C:\\Users\\BUDGET UNIT\\Downloads\\SQL\\TERRAFORM\\Ubuntukeys.pem")
}*/

variable "keyname" {
  default = "Ubuntukey"
}

variable "ssh_port" {
  default = 212
}

variable "ssh_IP" {
  default = "154.160.1.91/32"
  type    = string
}

variable "ld_type" {
  default = "application"
  type    = string
}

variable "ami" {
  default = "ami-0e83be366243f524a"
  type    = string
}

variable "listener_forward_type" {
  default = "forward"
}