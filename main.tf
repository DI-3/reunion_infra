resource "google_storage_bucket" "Mithun_N_GCS12" {
  name = "universal-valve-bucket-sample-373803"
  location      = "US"
}


resource "google_cloud_run_service" "reunion_cr_service" {

    name = "reunion-service"
    location= var.region

    metadata {
      annotations = {
        "run.googleapis.com/client-name" = "terraform"
      }
    }
    
    template {
      spec {
        containers {
          image = "gcr.io/universal-valve-373803/reunion:587d1d96b7c472009964b4c5e1daafb44895abf0"
        }
      }
    }
}

resource "google_sql_database_instance" "reunion_data_store" {
  name     = "cloud-sql-instance"
  region   = "us-central1"
  database_version = "POSTGRES_11"
  settings {
    tier = "db-custom-1-3840"
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = ["allUsers"]
  }
}

