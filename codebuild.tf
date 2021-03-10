resource "aws_codebuild_project" "project" {
  name          = "${var.project}"
  description   = "${var.project} CodeBuild Project"
  build_timeout = "10"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "${var.docker_build_image}"
    type         = "LINUX_CONTAINER"
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/mitchellh/packer.git"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }
   
  source_version = "master"
  
  tags = {
    Environment = "Test"
  }  
  
  artifacts {
    type = "NO_ARTIFACTS"
  }
  
  cache {
    type     = "S3"
    location = aws_s3_bucket.example.bucket
  }  
  
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }  
}

