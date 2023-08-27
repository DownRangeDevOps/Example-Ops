/*****************************************
  Backend config
 *****************************************/
locals {
  artifact_policy_file = "app_artifact_cleanup_policy.json"
  artifact_policies    = ["delete-old", "keep-latest"]
  artifact_policy = [
    {
      name   = "delete-old",
      action = { "type" = "Delete" },
      condition = {
        tagState  = "any",
        olderThan = "1d"
      }
    },
    {
      name   = "keep-latest",
      action = { "type" = "Keep" },
      condition = {
        tagState    = "tagged",
        tagPrefixes = ["latest"]
      }
    }
  ]

  backend_image_name_parts = [
    "${local.region}-docker.pkg.dev",
    local.project_id,
    google_artifact_registry_repository.default.name,
    "exampleco-backend:latest"
  ]
  backend_image_name = join("/", local.backend_image_name_parts)
  backend_port       = 5000

  gcr_sa_id           = data.terraform_remote_state.project.outputs.sa_service_accounts_map["app"]["account_id"]
  github_sa_iam_email = data.terraform_remote_state.project.outputs.sa_iam_emails_map["github"]

}

data "terraform_remote_state" "project" {
  backend = "gcs"

  config = {
    bucket = "${var.global_org_name}-tfstate"
    prefix = "${var.environment}/project"
  }
}

resource "google_artifact_registry_repository" "default" {
  # required
  format        = "DOCKER"
  repository_id = "${local.project_id}-app"

  # optional
  description = "Docker reppsitory for the ${title(var.global_org_name)} backend app"
  labels      = local.sanitized_module_labels
  location    = local.region
  project     = local.project_id
}

resource "local_file" "policy" {
  filename        = "${google_artifact_registry_repository.default.name}.json"
  file_permission = "0666"
  content         = jsonencode(local.artifact_policy)
}

module "gcloud" {
  # https://github.com/terraform-google-modules/terraform-google-gcloud
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 2.0"

  platform              = var.global_kernal_type
  additional_components = ["beta"]

  create_cmd_entrypoint = "gcloud"
  create_cmd_body = (join(" ", [
    "artifacts repositories set-cleanup-policies",
    "${google_artifact_registry_repository.default.name}",
    "--project=${local.project_id}",
    "--location=${local.region}",
    "--policy=${google_artifact_registry_repository.default.name}.json",
    "--no-dry-run",
  ]))

  destroy_cmd_entrypoint = "gcloud"
  destroy_cmd_body = (join(" ", [
    "artifacts repositories delete-cleanup-policies",
    "${google_artifact_registry_repository.default.name}",
    "--policynames=${join(",", [for i in local.artifact_policy : i.name])}",
    "--project=${local.project_id}",
    "--location=${local.region}",
  ]))
}

module "cloud_run" {
  # https://github.com/GoogleCloudPlatform/terraform-google-cloud-run
  source  = "GoogleCloudPlatform/cloud-run/google"
  version = "~> 0.9"

  service_name = "${local.project_id}-gcr-app-backend"
  project_id   = local.project_id

  # required
  image    = local.backend_image_name
  location = local.region

  # optional
  container_concurrency = 3
  members               = ["allUsers"]
  service_account_email = local.gcr_sa_id
  service_labels        = local.sanitized_module_labels
  timeout_seconds       = 10
  ports = {
    "name" = "http1",
    "port" = local.backend_port,
  }

  depends_on = [google_artifact_registry_repository.default]

  # defaults
  # argument               = []
  # certificate_mode       = "NONE"
  # container_command      = []
  # domain_map_annotations = {}
  # domain_map_labels      = {}
  # encryption_key         = null
  # production_secret_vars        = []
  # production_vars               = []
  # force_override         = false
  # generate_revision_name = true
  # limits                 = null
  # requests               = {}
  # service_annotations    = { "run.googleapis.com/ingress" = "all" }
  # template_labels        = {}
  # verified_domain_name   = []
  # volume_mounts          = []
  # volumes                = []
  # template_annotations = {
  #   "autoscaling.knative.dev/maxScale" = 2,
  #   "autoscaling.knative.dev/minScale" = 1,
  #   "generated-by"                     = "terraform",
  #   "run.googleapis.com/client-name"   = "terraform"
  # }
  # traffic_split = [{
  #   "latest_revision" = true,
  #   "percent"         = 100,
  #   "revision_name"   = "v1-0-0",
  #   "tag"             = null
  # }]
}

resource "google_compute_region_network_endpoint_group" "cloud_run" {
  provider              = google-beta
  name                  = "${local.project_id}-app-neg-cloud-run-neg"
  network_endpoint_type = "SERVERLESS"
  region                = local.region

  cloud_run {
    service = module.cloud_run.service_name
  }
}
