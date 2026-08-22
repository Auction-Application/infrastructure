resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow tcp 5432 for psql for all inbound traffic and outbound is all protocols"

}

resource "aws_vpc_security_group_ingress_rule" "allow_psql_ingress" {
  security_group_id = aws_security_group.rds_sg.id
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.rds_sg.id
  from_port         = 0
  to_port           = 0
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
}




resource "aws_db_instance" "auction_db" {
  allocated_storage           = 10
  max_allocated_storage       = 20
  db_name                     = "auction_db"
  engine                      = "postgres"
  auto_minor_version_upgrade  = true
  skip_final_snapshot         = true
  publicly_accessible         = true
  instance_class              = "db.t4g.micro"
  network_type                = "IPV4"
  manage_master_user_password = true
  engine_version              = 18
  username                    = "auction_app"
  port                        = 5432
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]
}


