provider "google" {
  region  = local.region
  project = local.project_id
}

provider "google-beta" {
  region  = local.region
  project = local.project_id
}
