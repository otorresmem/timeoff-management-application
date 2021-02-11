##############################################################################################
# VARIABLES
##############################################################################################
variable "ecr_name" {
    description = "ECR Repository Name"
    type        = string
    default     = "gorilla-timeoff"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

