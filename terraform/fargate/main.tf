##############################################################################################
# PROVIDERS
##############################################################################################
provider "aws" {
  region     = var.region
}

##############################################################################################
# RESOURCES
##############################################################################################

# Providing a reference to our default VPC
resource "aws_default_vpc" "default_vpc" {}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = var.subnet_a
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = var.subnet_b
}

resource "aws_default_subnet" "default_subnet_c" {
  availability_zone = var.subnet_c
}

data "aws_ecr_repository" "timeoff_repo" {
  name = var.ecr_name
}

resource "aws_ecs_cluster" "timeoff_cluster" {
  name = var.cluster_name
}


resource "aws_ecs_task_definition" "timeoff_task" {
  family                   = var.task_family
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.task_def_name}",
      "image": "${data.aws_ecr_repository.timeoff_repo.repository_url}:${var.ecr_image_tag}",
      "essential": ${var.task_essentials},
      "portMappings": [
        {
          "containerPort": ${var.container_port},
          "hostPort": ${var.host_port}
        }
      ],
      "memory": ${var.task_memory},
      "cpu": ${var.task_cpu}
    }
  ]
  DEFINITION
  requires_compatibilities = [var.ecs_type]   # Stating that we are using ECS Fargate
  network_mode             = var.network_mode # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.task_memory  # Specifying the memory our container requires
  cpu                      = var.task_cpu     # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = var.iam_role
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = var.iam_assume_actions

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = var.iam_policy_arn
}

resource "aws_alb" "application_load_balancer" {
  name               = var.alb_name
  load_balancer_type = var.alb_type

  subnets = [ # Referencing the default subnets
    aws_default_subnet.default_subnet_a.id,
    aws_default_subnet.default_subnet_b.id,
    aws_default_subnet.default_subnet_c.id
  ]

  # Referencing the security group
  security_groups = [aws_security_group.load_balancer_security_group.id]
}

# Creating a security group for the load balancer
resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = var.port_protocol
    cidr_blocks = [var.cidr_ip] # Allowing traffic on port 80 just from Romell's computer
  }

  ingress {
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = var.port_protocol
    cidr_blocks = [var.cidr_ip] # Allowing traffic on port 443 just from Romell's computer
  }

  egress {
    from_port   = var.all_ports
    to_port     = var.all_ports
    protocol    = var.all_protocols
    cidr_blocks = [var.all_cidr]
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = var.lb_targetgroup_name
  port        = var.http_port
  protocol    = var.http_protocol
  target_type = var.lb_targetgroup_targetype
  vpc_id      = aws_default_vpc.default_vpc.id # Referencing the default VPC

  health_check {
    port                = var.container_port
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 20
    matcher             = "200,302"
  }

  depends_on = [aws_alb.application_load_balancer]
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn # Referencing our load balancer
  port              = var.http_port
  protocol          = var.http_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn # Referencing our target group
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn # Referencing our load balancer
  port              = var.https_port
  protocol          = var.https_protocol
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn # Referencing our target group
  }
}

resource "aws_ecs_service" "timeoff_service" {
  name                               = var.ecs_service_name                     # Naming our first service
  cluster                            = aws_ecs_cluster.timeoff_cluster.id       # Referencing our created Cluster
  task_definition                    = aws_ecs_task_definition.timeoff_task.arn # Referencing the task our service will spin up
  launch_type                        = var.ecs_type
  desired_count                      = var.ecs_service_desired_count            # Setting the number of containers to 3
  deployment_minimum_healthy_percent = var.minimum_healthy_percent

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn           # Referencing our target group
    container_name   = aws_ecs_task_definition.timeoff_task.family
    container_port   = var.container_port                             # Specifying the container port
  }

  network_configuration {
    subnets          = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id, aws_default_subnet.default_subnet_c.id]
    assign_public_ip = true                                           # Providing our containers with public IPs
    security_groups  = [aws_security_group.service_security_group.id] # Setting the security group
  }
}


resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = var.all_ports
    to_port   = var.all_ports
    protocol  = var.all_protocols

    security_groups = [aws_security_group.load_balancer_security_group.id] # Only allowing traffic in from the load balancer security group
  }

  egress {
    from_port   = var.all_ports
    to_port     = var.all_ports
    protocol    = var.all_protocols
    cidr_blocks = [var.all_cidr]
  }
}

data "aws_acm_certificate" "certificate" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "primary" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_alb.application_load_balancer.dns_name
    zone_id                = aws_alb.application_load_balancer.zone_id
    evaluate_target_health = true
  }
}