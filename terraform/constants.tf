locals {
  aws = {
    region        = "us-east-1"             # N. Virginia
    instance_ami  = "ami-0866a3c8686eaeeba" # Ubuntu Server 24.04 LTS 64-bit (x86)
    instance_type = "t2.micro"              # Free tier eligible
  }
}
