resource "aws_security_group" "proj_sg" {
  name        = "proj Security Group"
  description = "Allow inbound SSH and HTTP traffic and all outbound traffic."
}

resource "aws_vpc_security_group_egress_rule" "proj_sg_egress_all" {
  security_group_id = aws_security_group.proj_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "proj_sg_ingress" {
  security_group_id = aws_security_group.proj_sg.id

  for_each = {
    ssh  = 22
    http = 80
    mysql = 3306
    backend = 5000
  }

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = each.value
  to_port     = each.value
}
