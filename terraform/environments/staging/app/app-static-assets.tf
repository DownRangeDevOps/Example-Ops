/*****************************************
  Static assets config
 *****************************************/
resource "google_compute_backend_bucket" "static_assets" {
  name    = "${local.project_id}-app-backend-bucket-static-assets"
  project = local.project_id

  description = "${local.project_id} static assets bucket"
  bucket_name = local.static_assets_bucket_name
  enable_cdn  = true

  depends_on = [module.storage]
}
