resource "aws_codebuild_project" "project" {
  name          = var.project
  description   = "${var.project} CodeBuild Project"
  build_timeout = "10"
  service_role  = aws_iam_role.build_role.arn

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.docker_build_image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

  }
  source {
    type            = "GITHUB"
    location        = "https://github.com/lanru2001/aws-cicd-pipeline-project02.git"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }

  }

  source_version = "main" #master

  tags = {
    Environment = "Test"
  }

  artifacts {
    type     = "S3"
    location = aws_s3_bucket.app_web.bucket

  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.app_web.bucket
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

}

