/*****************************************
  Locals
 *****************************************/
locals {
  service_accounts = {
    github = {
      name        = "github"
      description = "GitHub Actions service account"
    }
    gcr = {
      name        = "app"
      description = "App service account"
    }
  }

  gcr_sa_roles = [
    "roles/iam.serviceAccountUser",
    "roles/iam.workloadIdentityUser",
    "roles/serverless.serviceAgent",
  ]

  gcr_sa_iam_email = merge(
    [for service_account in module.service_accounts : service_account.iam_emails]...
  )["app"]

  gcr_sa_id = merge(
    [for service_account in module.service_accounts : service_account.service_accounts_map]...
  )["app"]["id"]

  github_sa_iam_email = merge(
    [for service_account in module.service_accounts : service_account.iam_emails]...
  )["github"]

  github_sa_id = merge(
    [for service_accounts in module.service_accounts : service_accounts.service_accounts_map]...
  )["github"]["id"]

  github_exampleco_backend_repo  = "DownRangeDevOps/exampleco-backend"
  github_exampleco_frontend_repo = "DownRangeDevOps/exampleco-frontend"

  oidc_pool_name = try(data.terraform_remote_state.oidc.outputs.pool_name, "")
}

/*****************************************
  Service Accounts
 *****************************************/
module "service_accounts" {
  for_each = local.service_accounts

  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 3.0"

  # required
  project_id = local.project_id

  # optional
  description = each.value.description
  names       = [each.value.name]
  prefix      = "${local.project_id}-sa"

  # defaults
  # billing_account_id = ""
  # descriptions       = []
  # display_name       = "Terraform-managed service account"
  # generate_keys      = false
  # grant_billing_role = false
  # grant_xpn_roles    = false
  # org_id             = ""
  # project_roles      = []
}

/*****************************************
  Remote state
 *****************************************/
data "terraform_remote_state" "app" {
  backend = "gcs"

  config = {
    bucket = "${var.global_org_name}-tfstate"
    prefix = "${var.environment}/app"
  }
}

data "terraform_remote_state" "oidc" {
  backend = "gcs"

  config = {
    bucket = "${var.global_org_name}-tfstate"
    prefix = "${var.environment}/oidc"
  }
}

/*****************************************
  GCR
 *****************************************/
resource "google_service_account_iam_member" "gcr" {
  for_each = toset(local.gcr_sa_roles)

  service_account_id = local.gcr_sa_id
  role               = each.value
  member             = local.gcr_sa_iam_email
}

/*****************************************
  GitHub
 *****************************************/
resource "google_service_account_iam_member" "github" {
  for_each = toset([local.github_sa_id, local.gcr_sa_id])

  service_account_id = each.value
  role               = "roles/iam.serviceAccountUser"
  member             = local.github_sa_iam_email
}

resource "google_storage_bucket_iam_binding" "binding" {
  count = length(local.oidc_pool_name) > 0 ? 1 : 0 # When bootstrapping a new project, this won't exist

  bucket = data.terraform_remote_state.app.outputs.bucket_name
  role   = "roles/storage.admin"
  members = [
    local.github_sa_iam_email,
    "principalSet://iam.googleapis.com/${local.oidc_pool_name}/attribute.repository/${local.github_exampleco_frontend_repo}"
  ]
}

resource "google_artifact_registry_repository_iam_binding" "binding" {
  count = length(local.oidc_pool_name) > 0 ? 1 : 0 # When bootstrapping a new project, this won't exist

  repository = data.terraform_remote_state.app.outputs.artifact_registry_repository
  role       = "roles/artifactregistry.admin"
  members = [
    local.github_sa_iam_email,
    "principalSet://iam.googleapis.com/${local.oidc_pool_name}/attribute.repository/${local.github_exampleco_frontend_repo}"
  ]
}

resource "google_cloud_run_service_iam_member" "member" {
  project  = local.project_id
  location = local.region
  service  = data.terraform_remote_state.app.outputs.gcr_service_name
  role     = "roles/run.admin"
  member   = local.github_sa_iam_email
}

resource "google_service_account_iam_member" "beewax-frontend-repo" {
  count = length(local.oidc_pool_name) > 0 ? 1 : 0 # When bootstrapping a new project, this won't exist

  service_account_id = local.github_sa_id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${local.oidc_pool_name}/attribute.repository/${local.github_exampleco_frontend_repo}"
}

resource "google_service_account_iam_member" "exampleco-backend-repo" {
  count = length(local.oidc_pool_name) > 0 ? 1 : 0 # When bootstrapping a new project, this won't exist

  service_account_id = local.github_sa_id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${local.oidc_pool_name}/attribute.repository/${local.github_exampleco_backend_repo}"
}
