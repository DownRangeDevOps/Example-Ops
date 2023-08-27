/*****************************************
  HTTP(s) Load-balancer
 *****************************************/
resource "random_id" "suffix" {
  byte_length = 2

  keepers = {
    # Change the suffix if the domain names change
    app_ssl_name = "${local.project_id}-app-ssl-certificate-${substr(sha256(join(" ", local.app_domains)), 0, 5)}"
  }
}

resource "google_compute_url_map" "default" {
  project     = local.project_id
  name        = "${local.project_id}-app-url-map-${random_id.suffix.hex}"
  description = "${var.global_org_name} ${var.environment} app url map"

  lifecycle {
    create_before_destroy = true
  }

  # redirect backend to gcr
  host_rule {
    hosts        = [local.backend_domain_name]
    path_matcher = "backend"
  }

  # gcr (backend)
  path_matcher {
    name            = "backend"
    default_service = nonsensitive(module.lb_http.backend_services["app-neg"].id)
  }

  # redirect everything else to cloud storage
  default_service = google_compute_backend_bucket.static_assets.id
}

resource "google_compute_managed_ssl_certificate" "default" {
  provider = google-beta

  project     = local.project_id
  name        = random_id.suffix.keepers.app_ssl_name
  description = "SSL certificate for ${var.global_org_name} app services"

  lifecycle {
    create_before_destroy = true
  }

  managed {
    domains = local.app_domains
  }
}

module "lb_http" {
  # https://github.com/terraform-google-modules/terraform-google-lb-http/
  source = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  # source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 9.1"

  # required
  project = local.project_id
  name    = "${local.project_id}-lb"
  backends = {

    app-neg = {
      groups      = [{ group = google_compute_region_network_endpoint_group.cloud_run.self_link }]
      enable_cdn  = false
      description = "${local.project_id}-lb-http-cloud-run-backend"

      log_config = {
        enable      = true
        sample_rate = 0.5
      }

      iap_config = {
        enable = false
      }
    }
  }

  # optional
  labels  = local.sanitized_module_labels
  network = "default"
  url_map = google_compute_url_map.default.self_link

  # ssl
  certificate          = google_compute_managed_ssl_certificate.default.self_link
  create_url_map       = false
  http_forward         = true
  https_redirect       = true
  ssl                  = true
  ssl_certificates     = [google_compute_managed_ssl_certificate.default.self_link]
  use_ssl_certificates = true

  # defaults
  # address                         = null
  # certificate_map                 = null
  # managed_ssl_certificate_domains = []
  # create_address                  = true
  # create_ipv6_address             = false
  # edge_security_policy            = null
  # enable_ipv6                     = false
  # ipv6_address                    = null
  # load_balancing_scheme           = "EXTERNAL"
  # private_key                     = null
  # quic                            = null
  # random_certificate_suffix       = false
  # security_policy                 = null
  # ssl_policy                      = null
}
