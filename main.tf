// vpc code 
resource "aws_vpc" "vpc1" {
  cidr_block = "172.120.0.0/16"
  instance_tenancy = "default"
enable_dns_hostnames = true
enable_dns_support = true
  tags = {
    name= "utc-app"
    env = "Dev"
    Team = "Devops"
  }
}

# internet gateway 
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name= "utc-app"
    env = "Dev"
    Team = "Devops"
  }
}

# Subenet public 
resource "aws_subnet" "pusub1" {
vpc_id = aws_vpc.vpc1.id
map_public_ip_on_launch = true
cidr_block = "172.120.1.0/24"
availability_zone = "us-east-1a"
tags = {
  Name= "public-useast-1a"
}
}

resource "aws_subnet" "pusub2" {
vpc_id = aws_vpc.vpc1.id
map_public_ip_on_launch = true
cidr_block = "172.120.2.0/24"
availability_zone = "us-east-1b"
 tags = {
    Name= "public-useast-1b"
  }
}
# private subnets
resource "aws_subnet" "privsub1" {
  vpc_id = aws_vpc.vpc1.id
  availability_zone = "us-east-1a"
  cidr_block = "172.120.3.0/24"
  tags = {
    Name = "private-us-east-1a"
  }
}
resource "aws_subnet" "privsub2" {
  vpc_id = aws_vpc.vpc1.id
  availability_zone = "us-east-1b"
  cidr_block = "172.120.4.0/24"
  tags = {
    Name = "private-us-east-1b"
  } 
}

# Nat gateway 
resource "aws_eip" "eip1" {
  
}
resource "aws_nat_gateway" "gtw1" {
subnet_id = aws_subnet.pusub1.id
allocation_id = aws_eip.eip1.id
tags = {
  Name = "Nategateway"
}
}


# Private route table 
resource "aws_route_table" "rt1" {
vpc_id = aws_vpc.vpc1.id
route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gtw1.id
}
}

# piblic route table 

resource "aws_route_table" "rt2" {
vpc_id = aws_vpc.vpc1.id
route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
}
  
}

# private route table association 

resource "aws_route_table_association" "rta1" {
 subnet_id = aws_subnet.privsub1.id
 route_table_id = aws_route_table.rt1.id

}
resource "aws_route_table_association" "rta2" { 
 subnet_id = aws_subnet.privsub2.id
 route_table_id = aws_route_table.rt1.id
}

#public route table association 

resource "aws_route_table_association" "rtpub1" {
subnet_id = aws_subnet.pusub1.id
route_table_id = aws_route_table.rt2.id
}

resource "aws_route_table_association" "rtpub2" {  
subnet_id = aws_subnet.pusub2.id
route_table_id = aws_route_table.rt2.id
} 

