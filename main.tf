data "aws_availability_zones" "available" {}

resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

# Security group 
resource "aws_security_group" "pipeline_security_group" {
  name                      = "${local.module_prefix}-sg"
  description               = "Allow traffic for instances"
  vpc_id                    = aws_vpc.pipeline_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    =  -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
      aws_vpc.pipeline_vpc   
  ]
}

resource "aws_network_interface"  "uclib_interface" {
  count                 = var.create ? 2:0 
  subnet_id             = var.pipeline_public_subnets[count.index].id 
  tags =  {

    Name = var.name
  }

}

resource "aws_instance" "webserver" {
  ami                    = var.AMI
  instance_type          = var.instance_type
  key_name               = aws_key_pair.mykeypair.key_name
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  user_data              = file("userdata.sh")
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "web_server"
  }
  #provisioner "file" {
  #  source      = "index.html"
  #  destination = "/tmp/index.html"
  #  connection {
  #    host = aws_instance.webserver.public_ip
  #    type     = "ssh"
  #    user     = "ec2-user"
  #    private_key =  file(var.PATH_TO_PRIVATE_KEY)
  #    timeout = "2m"
  #  }
  #}

}

# At least two subnets in two different Availability Zones must be specified
# Deploy ALB resource block, listener, security group, and target group
# create an Application Load Balancer.
# attach the previous availability zones' subnets into this load balancer.
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  enable_deletion_protection = true
  internal           = false         # set lb for public access
  load_balancer_type = "application" # use Application Load Balancer
  security_groups    = [aws_security_group.my_alb_security_group.id]
  subnets = [
    aws_subnet.public-subnets[0].id, aws_subnet.public-subnets[1].id, aws_subnet.public-subnets[2].id
  ]
  tags = {
    Environment = "Dev"
  }
  access_logs {
    bucket  = aws_s3_bucket.alb.bucket
    enabled = false
  }

}

# prepare a security group for our load balancer my_alb.
resource "aws_security_group" "my_alb_security_group" {
  vpc_id = aws_vpc.app-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create an alb listener for my_alb. forward rule: only accept incoming HTTP request on port 80, then it'll be forwarded to port target:8080.
resource "aws_lb_listener" "my_alb_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.my_alb_target_group.arn
    type             = "forward"
  }
}

# my_alb will forward the request to a particular app,
# that listen on 8080 within instances on my_vpc.
resource "aws_lb_target_group" "my_alb_target_group" {
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.app-vpc.id
}

#Define launch config and it's required dependencies for auto-scaling.Setup launch configuration for the auto-scaling.
resource "aws_launch_configuration" "my_launch_configuration" {
  # Amazon Linux 2 AMI (HVM), SSD Volume Type (ami-0f02b24005e4aec36).
  image_id        = var.AMI
  instance_type   = var.instance_type
  key_name        = aws_key_pair.mykeypair.key_name
  security_groups = [aws_security_group.my_launch_config_security_group.id, ]

  # set to false on all  stage.Otherwise true, because ssh access might be needed to the instance.
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }

  # execute bash scripts inside userdata.sh on instance's bootstrap.
  user_data = file("userdata.sh")
  # provisioner "file" {
  #   source      = "index.html"
  #   destination = "/tmp/index.html"
  #   connection {
  #     host = "${aws_instance.webserver.public_ip}"
  #     type     = "ssh"
  #     user     = "ec2-user"
  #     private_key = file(var.PATH_TO_PRIVATE_KEY)
  #     timeout = "2m"
  #   }
  # }

}

# security group for launch config my_launch_configuration.
resource "aws_security_group" "my_launch_config_security_group" {
  vpc_id = aws_vpc.app-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create an autoscaling then attach it into my_alb_target_group.
resource "aws_autoscaling_attachment" "my_aws_autoscaling_attachment" {
  alb_target_group_arn   = aws_lb_target_group.my_alb_target_group.arn
  autoscaling_group_name = aws_autoscaling_group.my_autoscaling_group.id
}

# define the autoscaling group attach my_launch_configuration into this newly created autoscaling group below.
resource "aws_autoscaling_group" "my_autoscaling_group" {
  name              = "my-autoscaling-group"
  desired_capacity  = 1     # ideal number of instance alive
  min_size          = 1     # min number of instance alive
  max_size          = 2     # max number of instance alive
  health_check_type = "EC2" #"ELB"

  # allows deleting the autoscaling group without waiting
  # for all instances in the pool to terminate
  force_delete = true

  dynamic "tag" {
    for_each = local.tags
    content {
      key                 = tag.value["key"]
      value               = tag.value["value"]
      propagate_at_launch = tag.value["propagate_at_launch"]
    }
  }

  launch_configuration = aws_launch_configuration.my_launch_configuration.id
  vpc_zone_identifier = [
    aws_subnet.public-subnets[0].id,
  ]
  timeouts {
    delete = "15m" # timeout duration for instances
  }
  lifecycle {
    # ensure the new instance is only created before the other one is destroyed.
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name                = "cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120" #seconds
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  dimensions = {
    InstanceId = aws_instance.webserver.id
  }
}

