servers = {
  "server1" = {
    region               = "ap-southeast-1"
    vpc_id               = null
    vpc_cidr_block       = "10.0.0.0/16"
    subnet_id            = null
    subnet_cidr_block_1  = "10.0.1.0/24"  # First subnet
    subnet_cidr_block_2  = "10.0.2.0/24"  # Second subnet
    instance_type        = "t2.micro"
    ami_id               = "ami-0672fd5b9210aa093"
    vpc_name             = "custom-vpc-1"
    subnet_1_name        = "custom-subnet-1"
    subnet_2_name        = "custom-subnet-2"
    igw_name             = "custom-igw"
    route_table_name     = "custom-route-table"
    security_group_id    = null
    security_group_name  = "custom-security-group"
    key_pair_name        = "custom-key-pair"
    ec2_instance_name    = "custom-ec2-instance"
    private_ip           = "10.0.1.10"  # ✅ Fix: Must be inside subnet CIDR range
    script_path          = "./push_to_github.ps1"
    user_data            = <<-EOF
                            #!/bin/bash
                            sudo apt-get update -y
                            sudo apt-get install -y apache2
                            sudo systemctl start apache2
                            sudo systemctl enable apache2
                            EOF
  }

  # "server2" = {
  #   region               = "ap-southeast-1"
  #   vpc_id               = "vpc-049fe9c5cc6dddc17"
  #   subnet_id            = "subnet-02b4445825f12d383"
  #   instance_type        = "t2.micro"
  #   ami_id               = "ami-0672fd5b9210aa093"
  #   security_group_id    = "sg-00e6c4e1a6674e62f"
  #   key_pair_name        = "shared-key-new"
  #   ec2_instance_name    = "custom-ec2-instance-2"
  #   private_ip           = null
  #   igw_id               = "igw-028abe28fa5da3ab7"
  #   script_path          = "data.ps1" 
  #    }
  
  #  "server3" = {
  #   region               = "ap-southeast-1"
  #   vpc_id               = "vpc-01ddb5a3185473d50"
  #   subnet_id            = "subnet-0cb0668e668ebec9f"
  #   instance_type        = "t2.micro"
  #   ami_id               = "ami-0672fd5b9210aa093"
  #   security_group_id    = "sg-0e98cdc67bb4973e1"
  #   key_pair_name        = "shared-key-new1"
  #   ec2_instance_name    = "custom-ec2-instance-2"
  #   private_ip           = null
  #   igw_id               = "igw-02cd82ae922c8f205"
  # }

  # "server4" = {
  #   region               = "ap-southeast-1"
  #   vpc_id               = null
  #   vpc_cidr_block       = "192.168.0.0/16"
  #   subnet_id            = null
  #   subnet_cidr_block_1  = "192.168.1.0/24"  # First subnet
  #   subnet_cidr_block_2  = "192.168.2.0/24"  # Second subnet
  #   instance_type        = "t2.micro"
  #   ami_id               = "ami-0672fd5b9210aa093"
  #   vpc_name             = "custom-vpc-2"
  #   subnet_1_name        = "custom-subnet-1-0"
  #   subnet_2_name        = "custom-subnet-2-0"
  #   igw_name             = "custom-igw-1"
  #   route_table_name     = "custom-route-table-1"
  #   security_group_id    = null
  #   security_group_name  = "custom-security-group-2"
  #   key_pair_name        = "custom-key--1"
  #   ec2_instance_name    = "custom-ec2--1"
  #   private_ip           = "192.168.1.10"  # ✅ Fix: Must be inside subnet CIDR range
  # }
}
