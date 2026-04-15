terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # For the first run you will need to comment this as backend S3 is not yet created.
  # After creation of the bucket you can uncomment this and migrate the state to the s3 by running:
  # terraform init -migrate-state

  backend "s3" {
    key          = "core/eu-west-1/terraform.tfstate"
    bucket       = "companyNM-infra-terraform-staging-8f403v"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}
