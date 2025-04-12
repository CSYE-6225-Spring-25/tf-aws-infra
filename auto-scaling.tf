# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  name                      = "csye6225_asg"
  desired_capacity          = 3
  max_size                  = 5
  min_size                  = 2
  default_cooldown          = 60
  vpc_zone_identifier       = aws_subnet.public[*].id
  target_group_arns         = [aws_lb_target_group.app_target_group.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.csye6225_asg.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ec2-webapp-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# CloudWatch Alarm for Scaling Up
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 9
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  alarm_description   = "Scale up if CPU utilization exceeds 7%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

# CloudWatch Alarm for Scaling Down
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 6
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  alarm_description   = "Scale up if CPU utilization goes below 5%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}
# Application Load Balancer
resource "aws_lb" "app_load_balancer" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_security_group.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = {
    Name = "app-load-balancer"
  }
}

# Target Group for the Application
resource "aws_lb_target_group" "app_target_group" {
  name        = "app-target-group"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    interval            = 120
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    path                = "/healthz"
    matcher             = "200"
    protocol            = "HTTP"
  }

  tags = {
    Name = "app-target-group"
  }
}

#resource "aws_lb_listener" "app_listener" {
# load_balancer_arn = aws_lb.app_load_balancer.arn
# port              = 80
# protocol          = "HTTP"

#default_action {
#type             = "forward"
#target_group_arn = aws_lb_target_group.app_target_group.arn
#}
#}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:600627322188:certificate/1527c7a4-ac84-4540-bfb6-17525e355430"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}