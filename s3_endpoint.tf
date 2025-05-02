

/////////////////////////////////////////////////////[ VPC S3 ENDPOINT ]//////////////////////////////////////////////////

# # ---------------------------------------------------------------------------------------------------------------------#
# S3 VPC Endpoint Gateway
# # ---------------------------------------------------------------------------------------------------------------------#
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids   = [for rt in values(aws_route_table.private) : rt.id]
  vpc_endpoint_type = "Gateway"
  tags = {
    Name = "${var.project}-s3-endpoint"
  }
}
