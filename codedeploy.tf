resource "aws_codedeploy_app" "application_deploy" {
  compute_platform = "Server"
  name             = "application-deploy"
}

resource "aws_codedeploy_deployment_config" "application_deploy" {
  deployment_config_name = "application-deploy-config"
  compute_platform       = "Server"
  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 4
  }
}

resource "aws_codedeploy_deployment_group" "app_deploy" {
  app_name               = aws_codedeploy_app.application_deploy.name
  deployment_group_name  = var.group_name
  service_role_arn       = aws_iam_role.deploy_role.arn
  deployment_config_name = aws_codedeploy_deployment_config.application_deploy.id

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 60
  }
  
  green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
  }
  
  terminate_blue_instances_on_deployment_success {
      action = "KEEP_ALIVE"
      }
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "aws:autoscaling:groupName" # key and value of your ec2 instance tag 
      type  = "KEY_AND_VALUE"
      value = "my-autoscaling-group"

    }

    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "web_server"
    }

    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "app-server"
    }

  }

  load_balancer_info {
    elb_info {
      name = aws_lb.my_alb.name
    }
  }

  autoscaling_groups = [ aws_autoscaling_group.my_autoscaling_group.name  ]
  
  #trigger_configuration {
  #  trigger_events     = ["DeploymentFailure"]
  #  trigger_name       = "app_deploy-trigger"
  #  trigger_target_arn = "app_deploy-topic-arn"
  #}

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  alarm_configuration {
    alarms  = ["my-alarm-name"]
    enabled = true
  }

}
