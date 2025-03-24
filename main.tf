# main.tf

# Create a VPC with a specific CIDR block
resource "aws_vpc" "custom_vpc" {
  for_each = { for k, v in var.servers : k => v if v.vpc_id == null }

  cidr_block = each.value.vpc_cidr_block
  tags = {
    Name = each.value.vpc_name
  }
}

# Create Subnets only for new VPCs
resource "aws_subnet" "custom_subnet_1" {
  for_each = { for k, v in var.servers : k => v if v.subnet_id == null }


  vpc_id            = aws_vpc.custom_vpc[each.key].id
  cidr_block        = each.value.subnet_cidr_block_1
  availability_zone = "${each.value.region}a"
  tags = {
    Name = each.value.subnet_1_name
  }
}

resource "aws_subnet" "custom_subnet_2" {
  for_each = { for k, v in var.servers : k => v if v.subnet_id == null }

  vpc_id            = aws_vpc.custom_vpc[each.key].id
  cidr_block        = each.value.subnet_cidr_block_2
  availability_zone = "${each.value.region}b"
  tags = {
    Name = each.value.subnet_2_name
  }
}

# Create an Internet Gateway only if a new VPC is created
resource "aws_internet_gateway" "igw" {
  for_each = { for k, v in var.servers : k => v if v.vpc_id == null }

  vpc_id = aws_vpc.custom_vpc[each.key].id
  tags = {
    Name = each.value.igw_name
  }
}


# Create a Route Table for each server
resource "aws_route_table" "public_route_table" {
  for_each = var.servers

  vpc_id = lookup(each.value, "vpc_id", null) != null ? each.value.vpc_id : aws_vpc.custom_vpc[each.key].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = each.value.igw_id != null ? each.value.igw_id : try(aws_internet_gateway.igw[each.key].id, null)
  }

  tags = {
    Name = coalesce(each.value.route_table_name, "default-route-table")
  }
}


resource "aws_route_table_association" "subnet_association_1" {
  for_each = { for k, v in var.servers : k => v if v.subnet_id == null }  # ✅ Skip association for existing subnets
  subnet_id      = aws_subnet.custom_subnet_1[each.key].id
  route_table_id = aws_route_table.public_route_table[each.key].id
}

resource "aws_route_table_association" "subnet_association_2" {
  for_each = { for k, v in var.servers : k => v if v.subnet_id == null }  # ✅ Skip association for existing subnets
  subnet_id      = aws_subnet.custom_subnet_2[each.key].id
  route_table_id = aws_route_table.public_route_table[each.key].id
}



# Security group to allow SSH, HTTP, and HTTPS access
resource "aws_security_group" "allow_web_traffic" {
  for_each = { for k, v in var.servers : k => v if v.security_group_id == null }

  vpc_id = aws_vpc.custom_vpc[each.key].id



  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = each.value.security_group_name
  }
}

# Generate an SSH key pair
resource "tls_private_key" "ssh" {
 for_each = var.servers
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "web_key" {
  for_each   = var.servers
  key_name   = each.value.key_pair_name
  public_key = tls_private_key.ssh[each.key].public_key_openssh
}


# Save the private key locally
resource "local_file" "private_key" {
  for_each = var.servers
  filename = "${each.value.key_pair_name}.pem"
  content  = tls_private_key.ssh[each.key].private_key_pem
}

# Launch EC2 instances
resource "aws_instance" "ubuntu_instance" {
  for_each                  = var.servers
  ami                       = each.value.ami_id
  instance_type             = each.value.instance_type
  subnet_id                 = coalesce(each.value.subnet_id, try(aws_subnet.custom_subnet_1[each.key].id, null))
  vpc_security_group_ids = each.value.security_group_id != null ? [each.value.security_group_id] : [aws_security_group.allow_web_traffic[each.key].id]

  key_name                  = aws_key_pair.web_key[each.key].key_name
  associate_public_ip_address = true
  private_ip = each.value.private_ip



  user_data = each.value.user_data

  tags = {
    Name = each.value.ec2_instance_name
  }

  provisioner "local-exec" {
    command = "powershell -ExecutionPolicy Bypass -File ${each.value.script_path}"
  }
}

# Allocate an Elastic IP address per instance
resource "aws_eip" "ec2_eip" {
  for_each = var.servers
  instance = aws_instance.ubuntu_instance[each.key].id
  tags     = { Name = "EC2ElasticIP-${each.key}" }
}

# Associate the Elastic IP with the EC2 instance
resource "aws_eip_association" "eip_association" {
  for_each      = var.servers
  instance_id   = aws_instance.ubuntu_instance[each.key].id
  allocation_id = aws_eip.ec2_eip[each.key].id
}

