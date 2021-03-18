resource "aws_s3_bucket" "app_web" {
  bucket = "${var.account_name}-application-web"
  acl    = "private"
  versioning {
    enabled = true
  }
  tags = {
    Name        = "application-web"
    Environment = "Dev"
  }
}


resource "aws_s3_bucket" "alb" {
  bucket = "${var.account_name}-alb"
  acl    = "private"
  versioning {
    enabled = true
  }
  tags = {
    Name        = "alb"
    Environment = "Dev"
  }
}
