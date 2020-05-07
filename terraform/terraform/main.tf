################################################
#Provider
################################################
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}
################################################
# vpc
################################################
resource "aws_vpc" "srs-vpc" {
  cidr_block = "${var.cidr_block}/24"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
  	Name = "${var.env}-${var.infra_version}-vpc"
  }
}

resource "aws_subnet" "srs-subnet-web" {
	vpc_id = "${aws_vpc.srs-vpc.id}"
  availability_zone = "${var.availability_zone}"
	cidr_block = "${var.cidr_block}/26"
	tags = {
  		Name = "${var.env}-${var.infra_version}-subnet-web"
  	}
}

resource "aws_subnet" "srs-subnet-private" {
	vpc_id = "${aws_vpc.srs-vpc.id}"
  availability_zone = "${var.availability_zone}"
	cidr_block = "${cidrhost("${var.cidr_block}/24", 64)}/26"
	tags = {
  		Name = "${var.env}-${var.infra_version}-subnet-private"
  	}
}


################################################
#internet gateway for public subnet
################################################
resource "aws_internet_gateway" "srs-igw" {
  vpc_id = "${aws_vpc.srs-vpc.id}"

  tags = {
    Name = "${var.env}-${var.infra_version}-igw"
  }
}

resource "aws_route_table" "srs-rt-web" {
  vpc_id = "${aws_vpc.srs-vpc.id}"

  tags = {
    Name = "${var.env}-${var.infra_version}-rt-web"
  }
}
resource "aws_route" "srs-rt-web_igw" {
  route_table_id = "${aws_route_table.srs-rt-web.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.srs-igw.id}"
}
resource "aws_route_table_association" "srs-rt-web_igw-to-subnet_web" {
  subnet_id      = "${aws_subnet.srs-subnet-web.id}"
  route_table_id = "${aws_route_table.srs-rt-web.id}"
}
################################################
# nat gateway for private subnet
################################################

resource "aws_eip" "nat_eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.srs-igw"]
    tags = {
    Name = "${var.env}-${var.infra_version}-NAT"
  }
}
resource "aws_nat_gateway" "srs-ngw" {
  subnet_id = "${aws_subnet.srs-subnet-web.id}"
  allocation_id = "${aws_eip.nat_eip.id}"
  tags = {
    Name = "${var.env}-${var.infra_version}-ngw"
  }
}
resource "aws_route_table" "srs-rt-ngw" {
  vpc_id = "${aws_vpc.srs-vpc.id}"

  tags = {
    Name = "${var.env}-${var.infra_version}-rt-ngw"
  }
}
resource "aws_route" "srs-rt-pvt_ngw" {
  route_table_id = "${aws_route_table.srs-rt-ngw.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_nat_gateway.srs-ngw.id}"
}
resource "aws_route_table_association" "srs-rt_pvt_ngw-to-subnet_pvt" {
  subnet_id      = "${aws_subnet.srs-subnet-private.id}"
  route_table_id = "${aws_route_table.srs-rt-ngw.id}"
}

################################################
# security group
################################################

resource "aws_security_group" "srs-sg-assignment" {
  name        = "SRS Assignment"
  description = "Rules for SRS Assignment Instance"
  vpc_id      = "${aws_vpc.srs-vpc.id}"
  ingress {
    from_port   = 95
    to_port     = 95
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${aws_subnet.srs-subnet-web.cidr_block}" ]
  }
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.infra_version}-sg-web"
  }
}



################################################
# EC2 Instances
################################################
#Get the AMI ID of latest ubuntu 18.04
data "aws_ami" "latest-ubuntu" {
most_recent = true
owners = ["099720109477"] # Canonical
  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

resource "aws_instance" "srs-ec2-assignment" {
  count = "${var.instance_count}"
  ami = "${data.aws_ami.latest-ubuntu.id}"
  instance_type = "${var.instance_type}"
  subnet_id = "${aws_subnet.srs-subnet-web.id}"
  associate_public_ip_address = "true"
  #public_dns = "true"
  key_name = "${var.key_name}"
  vpc_security_group_ids = [
    "${aws_security_group.srs-sg-assignment.id}"
  ]
    root_block_device {
    #device_name          = "/dev/sda1"
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }
  volume_tags = {
    Name = "${var.env}-${var.infra_version}-ec2-${count.index + 1}"
  }

  tags = {
    Name = "${var.env}-${var.infra_version}-ec2-${count.index + 1}"
  }
}