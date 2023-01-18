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
          image = "gcr.io/universal-valve-373803/reunion:latest"
        }
      }
    }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.reunion_cr_service.location
  project = var.project_id
  service = google_cloud_run_service.reunion_cr_service.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
