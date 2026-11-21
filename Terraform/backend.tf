terraform {
  backend "s3" {
    bucket       = "ivolve-terraform-state-essam-2026"
    key          = "terraform/state.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}