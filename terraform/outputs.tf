output "ec2_backend_instance_id" {
  value = aws_instance.proj_ec2_backend.id
}

output "ec2_backend_public_ip" {
  value = aws_instance.proj_ec2_backend.public_ip
}

output "ec2_frontend_instance_id" {
  value = aws_instance.proj_ec2_frontend.id
}

output "ec2_frontend_public_ip" {
  value = aws_instance.proj_ec2_frontend.public_ip
}

output "database_url" {
  value = aws_db_instance.db.endpoint
}
