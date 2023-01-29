module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${local.cluster_name}-state"
  acl    = "private"

  versioning = {
    enabled = true
  }
  tags = {
    Terraform   = "true"
    Environment = "${local.cluster_name}-server"
  }

}