provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  backend "gcs" {
    bucket = "universal-valve-373803-tfstate"
    prefix = "terraform/state"
  }
}