output "VPC_ID" {
    value = "${aws_vpc.srs-vpc.id}"
}
output "Public_subnet_ID" {
    value = "${aws_subnet.srs-subnet-web.id}"
}
output "Private_subnet_ID" {
    value = "${aws_subnet.srs-subnet-private.id}"
}

output "Internet_Gateway_ID" {
    value = "${aws_internet_gateway.srs-igw.id}"
}
output "NAT_Gateway_ID" {
    value = "${aws_nat_gateway.srs-ngw.id}"
}
output "NAT_Gateway_Elastic_Alloc_ID" {
    value = "${aws_eip.nat_eip.id}"
}
output "NAT_Gateway_Elastic_IP" {
    value = "${aws_eip.nat_eip.public_ip}"
}
output "Security_Group_ID_SRS_Instance" {
    value = "${aws_security_group.srs-sg-assignment.id}"
}

output "SRS_Instance_Public_IP" {
    value = "${aws_instance.srs-ec2-assignment.*.public_ip}"
}