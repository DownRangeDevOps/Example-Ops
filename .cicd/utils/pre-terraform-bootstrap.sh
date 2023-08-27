#! /usr/bin/env bash

function check_for_existing_group() {
  gcloud identity groups describe "$1"
}

function add_google_group() {
  gcloud identity groups create "$1" \
    --organization="downtownsb.com" \
    --display-name="$2" \
    --description="$3"
}

function pre_terraform_bootstrap() {
  GCP_GROUP_ORG_ADMINS="gcp-org-admins@downtownsb.com"
  GCP_GROUP_BILLING_ADMINS="gcp-billing-admins@downtownsb.com"

  if ! check_for_existing_group ${GCP_GROUP_ORG_ADMINS}; then
    printf "%s\n" "Adding ${GCP_GROUP_ORG_ADMINS} group..."
    add_google_group "${GCP_GROUP_ORG_ADMINS}" \
      "Group members have admin access to the organization" \
      "Organization Admins"
  else
    printf "%s\n" "${GCP_GROUP_ORG_ADMINS} group already exists, skipping."
  fi

  if ! check_for_existing_group ${GCP_GROUP_BILLING_ADMINS}; then
    printf "%s\n" "Adding ${GCP_GROUP_BILLING_ADMINS} group..."
    add_google_group "${GCP_GROUP_BILLING_ADMINS}" \
      "Group members have admin access to organization billing" \
      "Billing Admins"
  else
    printf "%s\n" "${GCP_GROUP_BILLING_ADMINS} group already exists, skipping."
  fi


}

pre_terraform_bootstrap
