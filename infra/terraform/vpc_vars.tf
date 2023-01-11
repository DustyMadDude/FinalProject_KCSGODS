variable "name" {
  description = "vpc name"
  type        = string
  default     = "yf-tf-eks"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_private_subnets" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_public_subnets" {
  type    = list(any)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}