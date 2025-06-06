

///////////////////////////////////////////////////////////[ NAT ENI ]////////////////////////////////////////////////////

# # ---------------------------------------------------------------------------------------------------------------------#
# Create EIP for EC2 NAT 
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_eip" "nat_gateway" {
  for_each          = aws_network_interface.nat_gateway
  domain            = "vpc"
  network_interface = aws_network_interface.nat_gateway[each.key].id
  depends_on        = [aws_internet_gateway.this]
  tags = {
    Name = "${var.project}-nat-gateway-${each.key}"
  }
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Create ENI for EC2 NAT
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_network_interface" "nat_gateway" {
  for_each          = aws_subnet.public
  description       = "${var.project} NAT EC2 Instance primary interface for ${each.key}"
  subnet_id         = aws_subnet.public[each.key].id
  source_dest_check = false
  security_groups   = [aws_security_group.nat_gateway.id]
  tags = {
    Name = "${var.project}-nat-gateway-${each.key}"
  }
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Create our EC2 NAT Gateway
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_instance" "nat_gateway" {
  for_each             = aws_subnet.public
  ami                  = data.aws_ami.this.id
  instance_type        = var.nat_gateway_instance_type
  iam_instance_profile = aws_iam_instance_profile.nat_gateway.name
  network_interface {
    network_interface_id = aws_network_interface.nat_gateway[each.key].id
    device_index         = 0
  }
  root_block_device {
    volume_size           = var.nat_gateway_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
    tags                  = { Name = "${var.project}-nat-gateway-volume-${each.key}" }
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  user_data = <<END
#!/bin/bash
### Install ssm manager
cd /tmp/
wget -q https://s3.${data.aws_region.current.name}.amazonaws.com/amazon-ssm-${data.aws_region.current.name}/latest/debian_$(dpkg --print-architecture)/amazon-ssm-agent.deb
dpkg -i amazon-ssm-agent.deb
systemctl enable amazon-ssm-agent
### Restart reconnect ssm manager
systemctl restart amazon-ssm-agent
END
  tags = {
    Name   = "${var.project}-nat-gateway-${each.key}"
    EC2NAT = "true"
  }
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Create EC2 service role for EC2 NAT Gateway
# # ---------------------------------------------------------------------------------------------------------------------#
data "aws_iam_policy_document" "nat_gateway_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
    sid    = "EC2NATGatewayRole"
  }
}
resource "aws_iam_role" "nat_gateway" {
  name               = "${var.project}-EC2-NAT-Gateway-Role"
  description        = "Allows EC2 instances to call AWS services on your behalf"
  assume_role_policy = data.aws_iam_policy_document.nat_gateway_assume_role.json
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Attach policies to EC2 service role for EC2 NAT Gateway
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_iam_role_policy_attachment" "nat_gateway" {
  role       = aws_iam_role.nat_gateway.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
# # ---------------------------------------------------------------------------------------------------------------------#
# Create EC2 Instance Profile for EC2 NAT Gateway
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_iam_instance_profile" "nat_gateway" {
  name = "${var.project}-EC2-NAT-Gateway-Profile"
  role = aws_iam_role.nat_gateway.name
}
