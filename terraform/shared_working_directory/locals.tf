//   Define your local variables here!
//
//   Local variables are meant for static values that don't need to be modified
//   between configurations / environments. See `variables.tf` for more
//   information on variables.

locals {
  // (string) Default GCP region, supplied to the GCP Terraform provider
  //   configuration. Resources which require region to be specified will use
  //   this value if not otherwise specified in the `resource` or `data`
  //   statement.
  region = "us-central1"
  // (string) Vault path where terraform managed service account keys will be written
  secrethandler_vault_path = "terraform_managed/${var.environment}/kv/secrets/sa-keys/${var.gcp_project_us}"
  export_writers = [
    "${var.export_excel_creator_cloudrun_name}@${var.gcp_project_us}.iam.gserviceaccount.com",
    "${var.export_zip_service_cloudrun_name}@${var.gcp_project_us}.iam.gserviceaccount.com",
    "${var.export_excel_processor_cloudrun_name}@${var.gcp_project_us}.iam.gserviceaccount.com",
    "export-service-es-kafka@${var.gcp_project_us}.iam.gserviceaccount.com"]

  export_readers = ["wf-gcp-ph-downloadcenter@wf-gcp-gb-appdata-dev.iam.gserviceaccount.com", "${var.export_zip_service_cloudrun_name}@${var.gcp_project_us}.iam.gserviceaccount.com", "export-service-es-kafka@${var.gcp_project_us}.iam.gserviceaccount.com"]

  gsm_secret_readers = [
    "${var.export_excel_creator_cloudrun_name}@${var.gcp_project_us}.iam.gserviceaccount.com",
    "${var.export_excel_processor_cloudrun_name}@${var.gcp_project_us}.iam.gserviceaccount.com",
    "export-service-es-kafka@${var.gcp_project_us}.iam.gserviceaccount.com"]
}
