variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "ha-eks-efs"
}

variable "cluster_version" {
  type    = string
  default = "1.29"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.10.48.0/20", "10.10.64.0/20", "10.10.80.0/20"]
}

# Optional: create a fully working HTTPS ingress via Terraform
variable "ingress_host" {
  type        = string
  description = "DNS hostname for your ingress (e.g. app.example.com). Leave empty to skip creating ingress."
  default     = ""
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM cert ARN in us-east-1 for HTTPS ALB. Required if ingress_host is set."
  default     = ""
}

variable "app_service_name" {
  type        = string
  description = "Kubernetes Service name to route traffic to."
  default     = "your-service"
}

variable "app_service_port" {
  type        = number
  description = "Kubernetes Service port number."
  default     = 80
}

variable "alb_controller_policy_arn" {
  type        = string
  description = "ARN of the customer-managed AWSLoadBalancerControllerIAMPolicy in your account"
}