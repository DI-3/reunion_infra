//   This is a sample Terraform configuration. 
//   You can add additional Terraform providers or workspaces as necessary.

terraform {
  required_version = ">= 1.2.3"

  // For terraform versions older than v1.1 backend "remote" {} block is used for configuring remote executions
  # backend "remote" {
  #   hostname     = "tfe.service.csnzoo.com"
  #   organization = "content"

  #   workspaces {
  #     tags = [ "repo:btbl-content-infra" ]
  #   }
  # }

  // For terraform versions newer than v1.1
  // cloud {} block is used for configuring remote executions
  cloud {
    hostname     = "tfe.service.csnzoo.com"
    organization = "content"

    workspaces {
      // if more than one workspace matches tags,
      // make sure to `terraform workspace select` correct workspace.
      tags = ["repo:btbl-content-infra"]

      // As an alternative to tags, you can explicitly set target  workspace name
      # name = "btbl-content-infra-dev"
    }
  }
  required_providers {
    google = {
      version = "~>4.6"
      source  = "hashicorp/google"
    }
    // (TODO) include this provider if you need to write
    //   and distribute service account keys through Vault.
    secrethandler = {
       source  = "tfproviders.csnzoo.com/wayfair/secrethandler"
       version = "~>1.1"
    }
  }
}

provider "google" {
  project = var.gcp_project_us
  region  = local.region
}

// (TODO) include secrethandler provider initialization if you need to write
//   and distribute service account keys through Vault.

// === secrethandler provider initialization ===
data "http" "jwt" {
  url = var.secrethandler_jwt_url
  request_headers = {
    "Metadata-Flavor" = "Google"
  }
}
provider "secrethandler" {
  vault_address = "https://vault.service.confiad1.consul.csnzoo.com:8200"
  vault_auth_login {
    path = "auth/gcp/login"
    parameters = {
      role = regex("tfe-[a-z-]+", var.secrethandler_jwt_url)
      jwt  = data.http.jwt.response_body
    }
  }
}
// === end of secrethandler provider initialization ===