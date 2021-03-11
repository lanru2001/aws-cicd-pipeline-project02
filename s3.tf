resource "aws_s3_bucket" "app_web" {
  bucket = "${var.account_name}-app-web"
  acl    = "private"     
  versioning {
    enabled = true 
  }
  tags = {
    Name        = "app-web"
    Environment = "Dev"
  }  
} 
