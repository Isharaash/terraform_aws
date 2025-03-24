variable "servers" {
  description = "Map of server configurations"
  type = map(object({
    region               = string
    vpc_id               = optional(string) # If provided, use existing VPC
    vpc_cidr_block       = optional(string) # If not provided, create a new VPC
    subnet_id            = optional(string) # If provided, use existing subnet
    subnet_cidr_block_1  = optional(string) # If not provided, create a new subnet
    subnet_cidr_block_2  = optional(string) # If not provided, create a new subnet
    instance_type        = string
    ami_id               = string
    vpc_name             = optional(string)
    subnet_1_name        = optional(string)
    subnet_2_name        = optional(string)
    igw_name             = optional(string)
    route_table_name     = optional(string)
    security_group_id    = optional(string) # If provided, use existing security group
    security_group_name  = optional(string)
    key_pair_name        = string
    ec2_instance_name    = string
    private_ip           = string
    igw_id               = optional(string) # If provided, use existing Internet Gateway
    script_path          = optional(string)
    user_data            = optional(string)

  }))
}

