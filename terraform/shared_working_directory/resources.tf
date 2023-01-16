// (TODO)  Define your resources here.
//   Any of the Terraform modules can be utilized here as well as Terraform
//   `resource` and `data` statements.

data "google_project" "project" {
}

data "google_compute_network" "vpc" {
  name = "default-network"
}

# module "cloudrun_batch-file-status-service" {
#   source             = "https://artifactorybase.service.csnzoo.com/artifactory/terraform/modules/tf-mod-cloudrun/tf-mod-cloudrun_v2.1.2.tar.gz"
#   name               = "batch-file-status-service"
#   project            = var.gcp_project_us
#   region             = "us-central1"
#   buildkite_pipeline = "batch-file-status-service"
#   invokers           = ["group:wf-gcp-supplier-catalog-eng@wayfair.com"]
# }

# module "cloudrun_batch-file-upload-service" {
#   source             = "https://artifactorybase.service.csnzoo.com/artifactory/terraform/modules/tf-mod-cloudrun/tf-mod-cloudrun_v2.1.2.tar.gz"
#   name               = "batch-file-upload-service"
#   project            = var.gcp_project_us
#   region             = "us-central1"
#   buildkite_pipeline = "batch-file-upload-service"
#   invokers           = ["group:wf-gcp-supplier-catalog-eng@wayfair.com"]
# }

module "cloudrun_content-product-attributes-export-excel-processor" {
  source             = "https://artifactorybase.service.csnzoo.com/artifactory/terraform/modules/tf-mod-cloudrun/tf-mod-cloudrun_v2.1.3.tar.gz"
  name               = var.export_excel_processor_cloudrun_name
  project            = var.gcp_project_us
  region             = "us-east4"
  buildkite_pipeline = "content-product-attributes-export-excel-processor"
  invokers           = ["group:wf-gcp-supplier-catalog-eng@wayfair.com"]
}

module "cloudrun_content-product-attributes-export-excel-creator" {
  source             = "https://artifactorybase.service.csnzoo.com/artifactory/terraform/modules/tf-mod-cloudrun/tf-mod-cloudrun_v2.1.3.tar.gz"
  name               = var.export_excel_creator_cloudrun_name
  project            = var.gcp_project_us
  region             = "us-east4"
  buildkite_pipeline = "content-product-attributes-export-excel-creator"
  invokers           = ["group:wf-gcp-supplier-catalog-eng@wayfair.com"]
}

module "cloudrun_export-zip-service-es" {
  source             = "https://artifactorybase.service.csnzoo.com/artifactory/terraform/modules/tf-mod-cloudrun/tf-mod-cloudrun_v2.1.3.tar.gz"
  name               = var.export_zip_service_cloudrun_name
  project            = var.gcp_project_us
  region             = "us-east4"
  buildkite_pipeline = "export-zip-service-es"
  invokers           = ["group:wf-gcp-supplier-catalog-eng@wayfair.com"]
}

resource "google_pubsub_schema" "excel_export_create_topic_schema" {
  name       = "excel-export-create-topic-schema"
  project    = var.gcp_project_us
  type       = "AVRO"
  definition = "{\"namespace\":\"com.wayfair.exportservicees.services\",\"type\":\"record\",\"name\":\"ContentProductAttributeCreateMsg\",\"doc\":\"ContentProductAttributePubSubCreateMessage.\",\"fields\":[{\"name\":\"taskId\",\"type\":\"string\",\"logicalType\":\"UUID\",\"doc\":\"UUIDtaskIDusedforExport/Searchcreation\"},{\"name\":\"supplierId\",\"type\":\"int\",\"doc\":\"SupplierIDofthesupplier\"},{\"name\":\"userId\",\"type\":[\"string\",\"null\"],\"doc\":\"PartnerHomeUserIDonwhosebehalfthisexportwascreated\"},{\"name\":\"employeeId\",\"type\":[\"string\",\"null\"],\"doc\":\"employeeIDwhichtriggeredthisexportonbehalfoftheuserreferencedinUserId\"},{\"name\":\"requestResourceType\",\"type\":\"string\",\"doc\":\"Uniquehumanreadabletoolnamewherethisrequestisgenerated.Ex:ProductAttributesExportorBulkEditSearch\"},{\"name\":\"exportFileName\",\"type\":\"string\",\"doc\":\"Uniqueexportfilename.Ex:Product_Attributes_Export_2022_12_27\"},{\"name\":\"dynamicData\",\"type\":{\"type\":\"map\",\"name\":\"dynamicData\",\"values\":\"string\",\"default\":{}},\"doc\":\"listofcustomvalues(e.g.mutationinputs)neededforthecontentproductattributesexport/searchgenerationprocessor\"}]}"
}

resource "google_pubsub_topic" "excel_export_create" {
  name    = "excel-export-create-topic"
  project = var.gcp_project_us

  depends_on = [google_pubsub_schema.excel_export_create_topic_schema]
  schema_settings {
    schema   = "projects/${var.gcp_project_us}/schemas/excel-export-create-topic-schema"
    encoding = "JSON"
  }
}

resource "google_pubsub_subscription" "excel_export_create_subscription" {
  name  = "excel-export-create-sub"
  topic = google_pubsub_topic.excel_export_create.name

  ack_deadline_seconds = 600

  push_config {
    push_endpoint = module.cloudrun_content-product-attributes-export-excel-creator.cloud_run_service_url
    oidc_token {
      service_account_email = "${var.export_excel_creator_cloudrun_name}@${var.gcp_project_us}.iam.gserviceaccount.com"
    }
    attributes = {
      x-goog-version = "v1"
    }
  }
}

#resource "google_pubsub_schema" "excel_export_process_schema" {
#  name       = "excel-export-process-schema"
#  project    = var.gcp_project_us
#  type       = "AVRO"
#  definition = "{\"namespace\":\"com.wayfair.suppliercatalog\",\"type\":\"record\",\"name\":\"ProductAttributeExcelExportCreateMsg\",\"doc\":\"ContentProductAttributeExcelExportPubSubCreateMessage.\",\"fields\":[{\"name\":\"taskId\",\"type\":\"string\",\"logicalType\":\"UUID\",\"doc\":\"UUIDtaskIDusedforExport/Searchcreation\"},{\"name\":\"supplierId\",\"type\":\"int\",\"doc\":\"SupplierIDofthesupplier\"},{\"name\":\"userId\",\"type\":[\"string\",\"null\"],\"doc\":\"PartnerHomeUserIDonwhosebehalfthisexportwascreated\"},{\"name\":\"employeeId\",\"type\":[\"string\",\"null\"],\"doc\":\"employeeIDwhichtriggeredthisexportonbehalfoftheuserreferencedinUserId\"},{\"name\":\"requestResourceType\",\"type\":\"string\",\"doc\":\"Uniquehumanreadabletoolnamewherethisrequestisgenerated.Ex:ProductAttributesExportorBulkEditSearch\"},{\"name\":\"dynamicData\",\"type\":{\"type\":\"map\",\"name\":\"dynamicData\",\"values\":\"string\",\"default\":{}},\"doc\":\"listofcustomvalues(e.g.mutationinputs)neededforthecontentproductattributesexport/searchgenerationprocessor\"}]}"
#}

resource "google_pubsub_topic" "excel_export_process" {
  name    = "excel-export-processor-topic"
  project = var.gcp_project_us
}

resource "google_pubsub_subscription" "excel_export_process_subscription" {
  project = var.gcp_project_us
  name    = "excel-export-process-sub"
  topic   = google_pubsub_topic.excel_export_process.name

  ack_deadline_seconds = 600

  push_config {
    push_endpoint = module.cloudrun_content-product-attributes-export-excel-processor.cloud_run_service_url
    oidc_token {
      service_account_email = "${var.export_excel_processor_cloudrun_name}@${var.gcp_project_us}.iam.gserviceaccount.com"
    }
    attributes = {
      x-goog-version = "v1"
    }
  }
}

# export-zip topic schema
resource "google_pubsub_schema" "export_service_zip_create_topic_schema" {
  name       = "export-service-zip-create-topic-schema"
  project    = var.gcp_project_us
  type       = "AVRO"
  definition = "{\"namespace\":\"com.wayfair.suppliercatalog\",\"type\":\"record\",\"name\":\"SupplierCatalogExportZipCreateMsg\",\"doc\":\"SupplierCatalogCreateexportzippubsubmessage.\",\"fields\":[{\"name\":\"taskId\",\"type\":\"string\",\"logicalType\":\"UUID\",\"doc\":\"UUIDtaskIDusedforExport/Searchcreation\"},{\"name\":\"fileTaskId\",\"type\":\"string\",\"logicalType\":\"UUID\",\"doc\":\"UUIDforindividualexcelfile\"},{\"name\":\"fileBlobName\",\"type\":[\"string\",\"null\"],\"doc\":\"UniqueblobIdforthefileuploadedtoGCP\"},{\"name\":\"filePath\",\"type\":[\"string\",\"null\"],\"doc\":\"FilepathoffilestoredinGCP\"},{\"name\":\"totalFileCount\",\"type\":\"int\",\"doc\":\"Totalnumberoffilesinthisexport\"},{\"name\":\"fileUploadStatus\",\"type\":\"boolean\",\"doc\":\"StatusofthefileuploadtoGCP\"},{\"name\":\"isZip\",\"type\":\"boolean\",\"doc\":\"Flagtodetermineiffilesshouldbezippedornot\"},{\"name\":\"exportFileName\",\"type\":[\"string\",\"null\"],\"doc\":\"Uniqueexportfilename\"},{\"name\":\"supplierId\",\"type\":\"int\",\"doc\":\"SupplierIDofthesupplier\"},{\"name\":\"userId\",\"type\":[\"string\",\"null\"],\"doc\":\"PartnerHomeUserIDonwhosebehalfthisexportwascreated\"},{\"name\":\"employeeId\",\"type\":[\"string\",\"null\"],\"doc\":\"employeeIDwhichtriggeredthisexportonbehalfoftheuserreferencedinUserId\"},{\"name\":\"requestResourceType\",\"type\":\"string\",\"doc\":\"Uniquehumanreadabletoolnamewherethisrequestisgenerated.Ex:ProductAttributesExportorBulkEditSearch\"}]}"
}

# export-zip topic
resource "google_pubsub_topic" "export_service_zip_create" {
  name    = "export-service-zip-create-topic"
  project = var.gcp_project_us

  depends_on = [google_pubsub_schema.export_service_zip_create_topic_schema]
  schema_settings {
    schema   = "projects/${var.gcp_project_us}/schemas/export-service-zip-create-topic-schema"
    encoding = "JSON"
  }
}
# export-zip subscription
resource "google_pubsub_subscription" "export_zip_service_es_subscription" {
  project = var.gcp_project_us
  name    = "export-zip-service-es-sub"
  topic   = google_pubsub_topic.export_service_zip_create.name

  ack_deadline_seconds = 600

  push_config {
    push_endpoint = module.cloudrun_export-zip-service-es.cloud_run_service_url
    oidc_token {
      service_account_email = "${var.export_zip_service_cloudrun_name}@${var.gcp_project_us}.iam.gserviceaccount.com"
    }
    attributes = {
      x-goog-version = "v1"
    }
  }
}

# Kafka connect pub-sub topic
resource "google_pubsub_topic" "export_completion_kafka_connect" {
  name    = "export-comp-kafka-connect-topic"
  project = var.gcp_project_us
}

# Kafka connect pub sub pull subscription
resource "google_pubsub_subscription" "export_comp_kafka_connect_sub" {
  project               = var.gcp_project_us
  name                  = "export-comp-kafka-connect-sub"
  topic                 = google_pubsub_topic.export_completion_kafka_connect.name
  retain_acked_messages = false
  expiration_policy {
    ttl = ""   // Never expire
  }
  retry_policy {
    minimum_backoff = "5s"
  }
}

#service-account for export_service_es_completion_kafka_connect
resource "google_service_account" "export_comp_kafka_connect" {
  account_id   = "export-comp-kafka-connect"
  display_name = "export-comp-kafka-connect"
  project      = var.gcp_project_us
}

#service-account secret handler for export_service_es_completion_kafka_connect
resource "secrethandler_sa_key" "terraform_sa_key_export_completion" {
  google_service_account_id = google_service_account.export_comp_kafka_connect.email
  vault_path                = "${local.secrethandler_vault_path}/${google_service_account.export_comp_kafka_connect.display_name}"
  vault_meta_policy {
    k8s_namespaces = ["export-service-es-completion-kafka-connect-dev"]
  }
}

# subscription privileges to kafka connect
resource "google_pubsub_subscription_iam_member" "topic-done-subscriber-ph-download-center-service" {
  subscription = google_pubsub_subscription.export_comp_kafka_connect_sub.name
  role         = "roles/pubsub.admin"
  member       = "serviceAccount:${google_service_account.export_comp_kafka_connect.email}"
}


resource "google_project_service_identity" "pubsub_agent" {
  provider = google-beta
  project  = var.gcp_project_us
  service  = "pubsub.googleapis.com"
}

resource "google_project_iam_member" "project_token_creator" {
  project = var.gcp_project_us
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_project_service_identity.pubsub_agent.email}"
}

#service-account for export-service-kafka-es
resource "google_service_account" "export_service_es_kafka" {
  account_id   = "export-service-es-kafka"
  display_name = "export-service-es-kafka"
  project      = var.gcp_project_us
}

resource "secrethandler_sa_key" "terraform_sa_key" {
  google_service_account_id = google_service_account.export_service_es_kafka.email
  vault_path                = "${local.secrethandler_vault_path}/${google_service_account.export_service_es_kafka.display_name}"
  vault_meta_policy {
    k8s_namespaces = ["export-service-kafka-es-dev"]
  }
}

#publisher for export-service-kafka-es
resource "google_pubsub_topic_iam_member" "topic-pub-sub-create-export-service-es-kafka" {
  topic  = google_pubsub_topic.excel_export_create.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.export_service_es_kafka.email}"
}

#Temporary: we will remove this after we finish local testing
resource "google_pubsub_topic_iam_member" "topic-status-pub-export-service-es-kafka-test" {
  topic  = google_pubsub_topic.excel_export_process.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.export_service_es_kafka.email}"
}

#Temporary: we will remove this after we finish local testing
resource "google_pubsub_topic_iam_member" "topic-zip-create-pub-export-service-es-kafka" {
  topic  = google_pubsub_topic.export_service_zip_create.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.export_service_es_kafka.email}"
}

#Temporary: we will remove this after we finish local testing to test pushing message to pubsub
resource "google_pubsub_topic_iam_member" "topic-status-pub-export-service-es-kafka-test-connect" {
  topic  = google_pubsub_topic.export_completion_kafka_connect.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.export_service_es_kafka.email}"
}

#cloud 1: export-excel-creator publisher access for topic: excel-export-processor-topic
resource "google_pubsub_topic_iam_member" "topic-status-pub-export-excel-creator" {
  topic  = google_pubsub_topic.excel_export_process.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${module.cloudrun_content-product-attributes-export-excel-creator.service_account_email}"
}

#cloud 2: export-excel-processor publisher access for topic: export-service-zip-create-topic
resource "google_pubsub_topic_iam_member" "topic-status-pub-export-processor-creator" {
  topic  = google_pubsub_topic.export_service_zip_create.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${module.cloudrun_content-product-attributes-export-excel-processor.service_account_email}"
}

#cloud 1: export-excel-creator publisher access for topic: export-completion-kafka-connect
resource "google_pubsub_topic_iam_member" "topic-status-pub-export-creator-kafka-connect" {
  topic  = google_pubsub_topic.export_completion_kafka_connect.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${module.cloudrun_content-product-attributes-export-excel-creator.service_account_email}"
}

#cloud 3: export-excel-zip-service publisher access for topic: export-completion-kafka-connect
resource "google_pubsub_topic_iam_member" "topic-status-pub-export-zip-service-kafka-connect" {
  topic  = google_pubsub_topic.export_completion_kafka_connect.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${module.cloudrun_export-zip-service-es.service_account_email}"
}

resource "google_storage_bucket" "export-excel-files" {
  name                        = var.export_excel_files_bucket_name
  project                     = var.gcp_project_us
  location                    = "US"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
}

#GCS for the Excel files created by Export Processor
resource "google_storage_bucket_iam_member" "export_writer" {
  for_each = toset(local.export_writers)
  bucket   = var.export_excel_files_bucket_name
  role     = "roles/storage.legacyBucketWriter"
  member   = "serviceAccount:${each.key}"
}

#GCS Content Bucket Object readers
resource "google_storage_bucket_iam_member" "export_object_reader" {
  for_each = toset(local.export_readers)
  bucket   = var.export_excel_files_bucket_name
  role     = "roles/storage.legacyObjectReader"
  member   = "serviceAccount:${each.key}"
}

# Create a GCP Role: US Central
module "eureka_proxy" {
  source = "https://artifactorybase.service.csnzoo.com/artifactory/terraform/modules/tf-mod-eureka-proxy/tf-mod-eureka-proxy_v2.0.11.tar.gz"

  gcp_project_number = data.google_project.project.number
  gcp_project_id     = var.gcp_project_us
  # This is currently static
  region                    = "us-central1"
  vpc_id                    = data.google_compute_network.vpc.id
  vpccon_enabled            = true
  target_service_attachment = var.target_service_attachment
  env                       = var.environment
  delegated_subdomain       = regex("^wf-gcp-\\w+-(.*)-\\w+$", var.gcp_project_us)[0]
}

// (TODO) Use this resource for reference if you need to create
//   a service account key and distribute it through Vault
# resource "secrethandler_sa_key" "terraform_sa_key" {
#   google_service_account_id = google_service_account.my_service_account.email
#   vault_path                = "${local.secrethandler_vault_path}/${google_service_account.my_service_account.display_name}"
#   vault_meta_policy {
#     bk_pipelines = ["my-bk-pipeline-slug"]
#   }
# }

# This is to test the GSM access 
resource "google_secret_manager_secret_iam_member" "export_secret_reader_test" {
  project = var.gcp_project_us
  secret_id = "supplier-catalog-product-content-es-s2s-client-secret"
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.export_service_es_kafka.email}"
}

#Access to secrets to access the external services
resource "google_secret_manager_secret_iam_member" "export_secret_reader" {
  for_each = toset(local.gsm_secret_readers)
  secret_id = "supplier-catalog-product-content-es-s2s-client-secret"
  role = "roles/secretmanager.secretAccessor"
  member   = "serviceAccount:${each.key}"
}
