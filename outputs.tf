output "vpc_ids" {
  description = "The IDs of the created VPCs"
  value       = { for key, vpc in aws_vpc.custom_vpc : key => vpc.id }
}

output "subnet_ids" {
  description = "The IDs of the created subnets"
  value = {
    for key, subnet in aws_subnet.custom_subnet_1 : key => {
      subnet_1 = subnet.id,
      subnet_2 = aws_subnet.custom_subnet_2[key].id
    }
  }
}

output "internet_gateway_ids" {
  description = "The IDs of the created Internet Gateways"
  value       = { for key, igw in aws_internet_gateway.igw : key => igw.id }
}

output "security_group_ids" {
  description = "The IDs of the created security groups"
  value       = { for key, sg in aws_security_group.allow_web_traffic : key => sg.id }
}

output "instance_public_ips" {
  description = "The public IP addresses of the EC2 instances"
  value       = { for key, instance in aws_instance.ubuntu_instance : key => instance.public_ip if instance.associate_public_ip_address }
}


output "elastic_ips" {
  description = "The allocated Elastic IP addresses"
  value       = { for key, eip in aws_eip.ec2_eip : key => eip.public_ip }
}