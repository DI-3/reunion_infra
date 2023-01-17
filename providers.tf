provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  backend "gcs" {
    bucket = "universal-valve-bucket-373803"
    prefix = "terraform/state"
  }
}