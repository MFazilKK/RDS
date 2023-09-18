
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Change to your desired AWS region
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16" # Replace with your VPC CIDR block
}

resource "aws_subnet" "example" {
  count                   = 1 # Change count to create multiple subnets if needed
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.0.0/24" # Replace with your desired subnet CIDR block
  availability_zone       = "us-east-1a"  # Replace with your desired availability zone
  map_public_ip_on_launch = false         # Set to true if you want instances in this subnet to have public IPs

  tags = {
    Name = "example-subnet"
  }
}

resource "aws_db_subnet_group" "example" {
  name       = "example-subnet-group"
  subnet_ids = [aws_subnet.example[0].id] # Use the ID of the created subnet
}

resource "aws_db_instance" "example" {
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t2.micro"
  username               = "admin"
  password               = "your_password_here"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.example.id]

  # Subnet group
  db_subnet_group_name = aws_db_subnet_group.example.name

  # Prevent public access
  publicly_accessible = false

  # Enable encryption (optional but recommended)
  storage_encrypted = true

  tags = {
    Name = "example"
  }
}

resource "aws_security_group" "example" {
  name        = "example"
  description = "Example security group for RDS"
}

resource "aws_security_group_rule" "example" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # Lock this down to specific IPs or ranges in production
  security_group_id = aws_security_group.example.id
}
