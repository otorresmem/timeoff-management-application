##############################################################################################
# VARIABLES
##############################################################################################
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "subnet_a" {
  description = "First subnet"
  type        = string
  default     = "us-east-1a"
}

variable "subnet_b" {
  description = "Second subnet"
  type        = string
  default     = "us-east-1b"
}

variable "subnet_c" {
  description = "Third subnet"
  type        = string
  default     = "us-east-1c"
}

variable "ecr_name" {
  description = "ECR Repository Name"
  type        = string
  default     = "gorilla-timeoff"
}

variable "ecr_image_tag" {
  description = "ECR Image tag"
  type        = string
  default     = "latest"
}

variable "cluster_name" {
  description = "ECS Cluster Name"
  type        = string
  default     = "timeoff-cluster"
}

variable "task_family" {
  description = "ECS Task Family"
  type        = string
  default     = "timeoff-task"
}

variable "task_def_name" {
  description = "ECS definition name"
  type        = string
  default     = "timeoff-task"
}

variable "task_essentials" {
  description = "ECS task essentials"
  type        = bool
  default     = true
}

variable "container_port" {
  description = "ECS container port"
  type        = number
  default     = 3000
}

variable "host_port" {
  description = "ECS host port"
  type        = number
  default     = 3000
}

variable "task_memory" {
  description = "Task memory required"
  type        = number
  default     = 1024
}

variable "task_cpu" {
  description = "CPU units required"
  type        = number
  default     = 512
}

variable "ecs_type" {
  description = "ECS type"
  type        = string
  default     = "FARGATE"
}

variable "network_mode" {
  description = "ECS network mode"
  type        = string
  default     = "awsvpc"
}
variable "iam_role" {
  description = "IAM Role"
  type        = string
  default     = "gorilla-role"
}

variable "iam_assume_actions" {
  description = "IAM assume tole actions"
  type        = list(any)
  default     = ["sts:AssumeRole"]
}

variable "iam_policy_arn" {
  description = "IAM policy arn"
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "alb_name" {
  description = "Application Load Balancer Name"
  type        = string
  default     = "timeoff-application"
}

variable "alb_type" {
  description = "Application Load Balancer type"
  type        = string
  default     = "application"
}

variable "http_port" {
  description = "HTTP port"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "HTTPS port"
  type        = number
  default     = 443
}

variable "port_protocol" {
  description = "Port protocol"
  type        = string
  default     = "tcp"
}

variable "cidr_ip" {
  description = "IP from Romell's computer to just allow access from it"
  type        = string
  default     = "190.171.15.174/32"
}

variable "all_cidr" {
  description = "All cidr block"
  type        = string
  default     = "0.0.0.0/0"
}

variable "all_protocols" {
  description = "All protocol"
  type        = string
  default     = "-1"
}

variable "all_ports" {
  description = "All ports"
  type        = number
  default     = 0
}

variable "lb_targetgroup_name" {
  description = "ALB Target Group name"
  type        = string
  default     = "timeoff-target-group"
}

variable "http_protocol" {
  description = "ALB Target Group protocol"
  type        = string
  default     = "HTTP"
}

variable "https_protocol" {
  description = "LB Listener HTTPS protocol"
  type        = string
  default     = "HTTPS"
}

variable "lb_targetgroup_targetype" {
  description = "ALB Target Group protocol"
  type        = string
  default     = "ip"
}


variable "ecs_service_name" {
  description = "ECS service name"
  type        = string
  default     = "timeoff-service" 
}

variable "ecs_service_desired_count" {
  description = "ECS desired count of tasks"
  type        = number
  default     = 3
}

variable "minimum_healthy_percent" {
  description = "ECS minimum_healthy_percent"
  type        = number
  default     = 50
}

variable "ssl_policy" {
  description = "SSL policy to certificate"
  type        = string
  default     = "ELBSecurityPolicy-2016-08"  
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "timeoff-example.link"
}