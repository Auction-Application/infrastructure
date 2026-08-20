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
}
