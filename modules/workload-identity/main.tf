locals{
    gsa_name = "jo-gsa" # make sure to set same value for GSA_NAME in the /scripts/configure-workload-identity.sh script
    ksa_name = "jo-ksa" # make sure to set same value for KSA_NAME in the /scripts/configure-workload-identity.sh script
}

data "google_project" "project" {
}

resource "google_service_account" "cluster_service_account" {
  account_id   = local.gsa_name
  display_name = "Jo GKE Cluster Service Account"
}

resource "google_service_account_iam_member" "iam_member" {
  service_account_id = google_service_account.cluster_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${data.google_project.project.project_id}.svc.id.goog[default/${local.ksa_name}]"
}

resource "google_project_iam_member" "workload_identity_sa_bindings" {
  for_each = toset(var.roles)
  role    = each.value
  member  = "serviceAccount:${google_service_account.cluster_service_account.email}"
  project = data.google_project.project.name
}
