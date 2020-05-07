variable "access_key" {
  default = ""
} 
variable "secret_key" {
  default = ""
} 

variable "region" {
  description = "The Region where the entire infrastructure will be created"
  default = "ap-south-1"
}

variable "availability_zone" {
  description = "The AZ where the resources gets created"
  default = "ap-south-1a"
}

variable "env" {
  description = "Specifies the name of the Environment"
  default = "srs-assignment"
}

variable "infra_version" {
  description = "Provides the version to the resources created"
  default = "v1.0"
}
variable "key_name" {
  description = "Key Pair name which was already created under the AWS account with-in the same region"
  default = "srs-assignment-awskey"
}

variable "cidr_block" {
  description = "IP Range to be used for the CIDR block under VPC"
  default = "10.220.0.0"
}


variable "instance_type" {
  description = "Instance Type used to create the  Instance"
  default = "t2.micro"
}

variable "instance_count" {
  description = "Number of instances to Spin"
  default = "5"
}
