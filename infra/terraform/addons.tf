variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      name    = "kube-proxy"
      version = "v1.24.9-eksbuild.1"
    },
    {
      name    = "vpc-cni"
      version = "v1.12.0-eksbuild.2"
    },
    {
      name    = "coredns"
      version = "v1.8.7-eksbuild.3"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.14.0-eksbuild.1"
    }
  ]
}
