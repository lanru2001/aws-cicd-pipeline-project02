
resource "aws_codepipeline" "pipeline_project" {
  name     = "${var.app}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.app_web.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["${var.app}"]

      configuration = {
        Owner                = "${var.github_org}"
        Repo                 = "${var.project}"
        PollForSourceChanges = "true"
        Branch               = "main" #master
        OAuthToken           = var.github_token

      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["${var.app}"]
      version         = "1"

      configuration = {
        ProjectName = "var.project" #"${aws_codebuild_project.project.name}"  
      }
    }
  }


  stage {
    name = "Approval"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      #configuration = {
      # NotificationArn = "${aws_sns_topic.pipeline_updates}"
      # }
    }
  }


  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["${var.app}"]
      version         = "1"

      configuration = {
        ApplicationName     = "${aws_codedeploy_app.application_deploy.name}"
        DeploymentGroupName = "${var.group_name}"

      }
    }
  }
}



resource "aws_codepipeline_webhook" "pipeline_project" {
  name            = "webhook-github-pipeline"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.pipeline_project.name

  authentication_configuration {
    secret_token = var.github_token 
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}


# Wire the CodePipeline webhook into a GitHub repository.
#resource "github_repository_webhook" "code_pipeline" {
#  repository = var.repository_name
#
#  name = "web"
#
#  configuration {
#    url          = "aws_codepipeline_webhook.pipeline_project.url"
#    content_type = "json"
#    insecure_ssl = true
#    secret = local.webhook_secret
#
#  }
#
#  events = ["push"]
#}
