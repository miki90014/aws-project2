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

/*data "aws_instance" "eb_instance" {
  filter {
    name   = "tag:elasticbeanstalk:environment-name"
    values = [aws_elastic_beanstalk_environment.proj_backend_env.name]
  }
}

output "public_url" {
  value = aws_elastic_beanstalk_environment.proj_backend_env.endpoint_url
}

output "instance_id" {
  value = data.aws_instance.eb_instance.id
}*/

output "database_url" {
  value = aws_db_instance.db.endpoint
}
