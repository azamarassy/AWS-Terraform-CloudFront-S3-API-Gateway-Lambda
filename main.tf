terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"
  tags = {
    Name = "public_subnet_2"
  }
}

# プライベートサブネットは不要（Lambdaは管理されたサービスのため）

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw"
  }
}

# NAT Gateway は不要（Lambdaはプライベートサブネットを使用しないため）

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "public-rt"
    }
}

# プライベートルートテーブルは不要（Lambdaはプライベートサブネットを使用しないため）

resource "aws_route_table_association" "public_1" {
    subnet_id = aws_subnet.public_1.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
    subnet_id = aws_subnet.public_2.id
    route_table_id = aws_route_table.public.id
}

# プライベートサブネット用のルートテーブルアソシエーションは不要