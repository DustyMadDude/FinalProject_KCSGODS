variable "name" {
  type    = string
  default = "yf-tf-eks-vpc"
}

variable "vpc_private_subnets" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_public_subnets" {
  type    = list(any)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}
variable "vpc_cidr" {
  type        = string
  description = "The IP range to use for the VPC"
  default     = "10.0.0.0/16"
}