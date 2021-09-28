terraform {
  required_providers {
    netapp-cloudmanager = {
      source  = "netapp/netapp-cloudmanager"
      version = "21.9.1"
    }
    gcp = {
      source = "hashicorp/google"
      version = "3.84.0"
    }
  }
}

# Define Cloud Manager variables
provider "netapp-cloudmanager" {
  refresh_token = var.refresh_token
}

# provider "google" {
#   project = "rt1611756"
#   /* Set credentials by exporting environment variable of json file
#   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service_account.json"
#   */
# }

locals {
  gcp = {
    project = "PROJECT_ID"
    network = "gcp-vpc-core"
    subnet = "gcp-vpc-core-private"
  }
  netapp = {
    account_id = "NETAPP_ACCOUNT_ID"
    company_name = "NetApp"
  }
}

##### GCP #####

# Enables GCP Services
resource "google_project_service" "rt1611756_services" {
  for_each = toset(var.gcp_services)

  project = local.gcp.project
  service = each.key
  disable_on_destroy = false
}

# Create GCP Customer IAM Role
resource "google_project_iam_custom_role" "connector_role" {
  depends_on = [google_project_service.rt1611756_services]
  project     = local.gcp.project
  role_id = "netappconnector"
  title = "NetApp Connector"
  permissions = var.connector_role
}

# Create Connector Service Account
resource "google_service_account" "connector_sa" {
  depends_on = [google_project_service.rt1611756_services]
  project     = local.gcp.project
  account_id = "netapp-connector"
  display_name = "NetApp Connector Service Account"
}

# Create Connector Service Account Policy Binding
resource "google_project_iam_binding" "connector_binding" {
  depends_on = [
    google_project_iam_custom_role.connector_role,
    google_service_account.connector_sa,
    google_project_service.rt1611756_services
  ]
  project     = local.gcp.project

  role = google_project_iam_custom_role.connector_role.name
  members = [
    format("serviceAccount:%s",google_service_account.connector_sa.email)
  ]
}

# Create CVO Service Account
resource "google_service_account" "cvo_sa" {
  depends_on = [google_project_service.rt1611756_services]
  project     = local.gcp.project
  account_id = "netapp-ontap"
  display_name = "NetApp CVO Service Account For Tiering and Backup"
}

# Create CVO Service Account Policy Binding
resource "google_project_iam_binding" "cvo_binding" {
  depends_on = [google_service_account.cvo_sa, google_project_service.rt1611756_services]

  project = local.gcp.project
  role = "roles/storage.admin"
  members = [
    format("serviceAccount:%s",google_service_account.cvo_sa.email)
  ]
}

# Bind Connector SA as User of CVO SA
resource "google_service_account_iam_binding" "connector_member_cvo" {
    depends_on = [google_service_account.cvo_sa, google_project_service.rt1611756_services]

    service_account_id = google_service_account.cvo_sa.id
    role = "roles/iam.serviceAccountUser"
    members = [
      format("serviceAccount:%s",google_service_account.connector_sa.email)
    ]
}

# Create GCP Firewall Policy for CVO
resource "google_compute_firewall" "cvo_rule" {
  depends_on = [google_project_service.rt1611756_services]
  project     = local.gcp.project
  name        = "netapp-cvo-firewall"
  network     = local.gcp.network
  description = "NetApp CVO allow from local IPs"
  source_ranges = var.src_ip_ranges

  allow {
    protocol  = "all"
  }
  target_tags = ["ntap-cvo"]
}

##### NTAP #####

# Build GCP Cloud Manager
resource "netapp-cloudmanager_connector_gcp" "occm_gcp" {
  depends_on = [
    google_project_service.rt1611756_services,
    google_project_iam_custom_role.connector_role,
    google_service_account.connector_sa,
    google_service_account_iam_binding.connector_member_cvo
  ]

  name = "insightconnectorgcp"
  zone = "us-east4-a"
  company = "NetApp"
  project_id = local.gcp.project
  service_account_email = google_service_account.connector_sa.email
  service_account_path = "./gcp_service_account.json"
  account_id = local.netapp.account_id
  subnet_id = local.gcp.subnet
  associate_public_ip = true
  firewall_tags = false
}

# Build GCP CVO
resource "netapp-cloudmanager_cvo_gcp" "cvo_gcp_us_east4" {
  depends_on = [
    netapp-cloudmanager_connector_gcp.occm_gcp,
    google_service_account.cvo_sa,
    google_service_account_iam_binding.connector_member_cvo,
    google_compute_firewall.cvo_rule
  ]

  name = "insightcvogcp"
  project_id = local.gcp.project
  zone = "us-east4-a"
  gcp_service_account = google_service_account.cvo_sa.email
  svm_password = "Netapp1!"
  client_id = netapp-cloudmanager_connector_gcp.occm_gcp.client_id
  firewall_rule = google_compute_firewall.cvo_rule.name
  writing_speed_state = "NORMAL"
  license_type = "gcp-cot-standard-paygo"
  instance_type = "n1-standard-8"
  subnet_id = local.gcp.subnet
  vpc_id = local.gcp.network
}
