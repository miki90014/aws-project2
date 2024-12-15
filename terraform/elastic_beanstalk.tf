/*resource "aws_elastic_beanstalk_application" "proj_backend_app" {
  name        = "proj-backend-app"
  description = "Backend application"
}

resource "aws_elastic_beanstalk_environment" "proj_backend_env" {
  name                = "proj-backend-env"
  application         = aws_elastic_beanstalk_application.proj_backend_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.4.1 running Docker"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforAutoScalingRole"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "BACKEND_PORT"
    value     = "5000"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_REGION"
    value     = "us-east-1"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "COGNITO_POOL_ID"
    value     = aws_cognito_user_pool.user_pool.id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "COGNITO_CLIENT_ID"
    value     = aws_cognito_user_pool_client.cognito_client.id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_URL"
    value     = aws_db_instance.db.endpoint
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_USERNAME"
    value     = "admin"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DATABASE_PASSWORD"
    value     = "adminadmin"
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_CREDENTIALS"
    value     = "${file("C:/Users/Monik/.aws/credentials")}"
  }

  depends_on = [
    aws_cognito_user_pool.user_pool,
    aws_cognito_user_pool_client.cognito_client,
    aws_db_instance.db
  ]
}

resource "aws_s3_bucket" "backend_bucket" {
  bucket = "python-backend-deployment"
}

resource "aws_s3_bucket_object" "dockerrun" {
  bucket = aws_s3_bucket.backend_bucket.id
  key    = "Dockerrun.aws.json"
  source = "Dockerrun.aws.json"
}

resource "aws_elastic_beanstalk_application_version" "app_version" {
  application = aws_elastic_beanstalk_application.proj_backend_app.name
  bucket      = aws_s3_bucket.backend_bucket.id
  key         = aws_s3_bucket_object.dockerrun.id
  name        = "v1"
}*/