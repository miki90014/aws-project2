resource "aws_db_instance" "db" {
  identifier             = "project-db"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.small"
  db_name                = "messages"
  username               = "admin"
  password               = "adminadmin"
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.proj_sg.id]

  depends_on = [
    aws_security_group.proj_sg,
  ]
}
