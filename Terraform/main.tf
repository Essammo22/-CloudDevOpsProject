resource "aws_s3_bucket" "terraform_state" {
  bucket = "ivolve-terraform-state-essam-2026"
  tags = {
    Name        = "Terraform State"
    Environment = "Dev"
    Project     = "iVolve"
  }

}
# Enable versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
module "network" {
  source = "./modules/network"

}
module "server" {
  source    = "./modules/server"
  vpc_id    = module.network.vpc_id
  subnet_id = module.network.public_subnet_id[0]

}
module "ecr" {
  source = "./modules/ecr"

}
module "eks" {
  source = "./modules/eks"

  cluster_name       = "ivolve-eks"
  private_subnet_ids = module.network.private_subnet_id
}