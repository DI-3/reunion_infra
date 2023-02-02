resource "google_storage_bucket" "Mithun_N_GCS12" {
  name = "universal-valve-bucket-sample-373803"
  location      = "US"
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


