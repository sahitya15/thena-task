resource "aws_lb" "app_alb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  access_logs {
    bucket  = "your-s3-bucket-for-alb-logs"
    enabled = true
  }

  tags = {
    Name = "${var.app_name}-alb"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.app_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "target_attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = var.target_id
  port             = 80
}