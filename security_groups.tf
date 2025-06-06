


////////////////////////////////////////////////////////[ SECURITY GROUPS ]///////////////////////////////////////////////

# # ---------------------------------------------------------------------------------------------------------------------#
# Create security group and rules for NAT EC2
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_security_group" "nat_gateway" {
  name        = "${var.project}-nat-gateway-sg"
  description = "Security group rules for ${var.project} NAT EC2"
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = "${var.project}-nat-gateway-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "nat_gateway" {
  description       = "Security group rules for NAT EC2 ingress"
  security_group_id = aws_security_group.nat_gateway.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "${var.project}-nat-gateway-ingress-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "nat_gateway" {
  description       = "Security group rules for NAT EC2 egress"
  security_group_id = aws_security_group.nat_gateway.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "${var.project}-nat-gateway-egress-sg"
  }
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Security Group for VPC Interface Endpoints
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_security_group" "vpc_endpoint" {
  name        = "${var.project}-vpc-endpoint-sg"
  description = "Security group for VPC Interface Endpoints"
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = "${var.project}-vpc-endpoint-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint" {
  description       = "Security group rules for VPC Interface Endpoints ingress"
  security_group_id = aws_security_group.vpc_endpoint.id
  ip_protocol       = "-1"
  cidr_ipv4         = aws_vpc.this.cidr_block
  tags = {
    Name = "${var.project}-vpc-endpoint-ingress-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "vpc_endpoint" {
  description       = "Security group rules for VPC Interface Endpoints egress"
  security_group_id = aws_security_group.vpc_endpoint.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "${var.project}-vpc-endpoint-egress-sg"
  }
}
