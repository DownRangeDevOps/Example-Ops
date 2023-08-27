variable "labels" {
  description = "A map of labels to to be filtered to comply with GCP restrictions."
  type        = map(string)
}

locals {
  sanitized_labels = {
    for k, v in var.labels
    : replace(lower(k), "/[^a-z0-9_-]/", "-")
    => replace(lower(v), "/[^a-z0-9_-]/", "-")
  }
}

output "labels" {
  value = local.sanitized_labels
}
