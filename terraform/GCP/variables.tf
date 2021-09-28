# Cloud Manager Refresh Token
variable "refresh_token" {
  default = "BJGL372evyr40m2icT8M4V_RGmpU_Y4ghDANSmFdHId8U"
}

# Source IP Ranges
variable "src_ip_ranges" {
  default = [
    "172.18.0.0/24", #GCP
    "10.221.0.0/16", #AWS
    "192.168.0.0/24" #onPrem
  ]
}

# GCP Services
variable "gcp_services" {
  default = [
      "deploymentmanager.googleapis.com",
      "logging.googleapis.com",
      "cloudresourcemanager.googleapis.com",
      "compute.googleapis.com",
      "iam.googleapis.com",
      "cloudkms.googleapis.com"
    ]
}

# Connector Role
variable "connector_role" {
  description = "Role for GCP Conenctor"
  default = [
    "iam.serviceAccounts.actAs",
    "compute.regionBackendServices.create",
    "compute.regionBackendServices.get",
    "compute.regionBackendServices.list",
    "compute.networks.updatePolicy",
    "compute.backendServices.create",
    "compute.addresses.list",
    "compute.disks.create",
    "compute.disks.createSnapshot",
    "compute.disks.delete",
    "compute.disks.get",
    "compute.disks.list",
    "compute.disks.setLabels",
    "compute.disks.use",
    "compute.firewalls.create",
    "compute.firewalls.delete",
    "compute.firewalls.get",
    "compute.firewalls.list",
    "compute.globalOperations.get",
    "compute.images.get",
    "compute.images.getFromFamily",
    "compute.images.list",
    "compute.images.useReadOnly",
    "compute.instances.attachDisk",
    "compute.instances.create",
    "compute.instances.delete",
    "compute.instances.detachDisk",
    "compute.instances.get",
    "compute.instances.getSerialPortOutput",
    "compute.instances.list",
    "compute.instances.setDeletionProtection",
    "compute.instances.setLabels",
    "compute.instances.setMachineType",
    "compute.instances.setMetadata",
    "compute.instances.setTags",
    "compute.instances.start",
    "compute.instances.stop",
    "compute.instances.updateDisplayDevice",
    "compute.machineTypes.get",
    "compute.networks.get",
    "compute.networks.list",
    "compute.projects.get",
    "compute.regions.get",
    "compute.regions.list",
    "compute.snapshots.create",
    "compute.snapshots.delete",
    "compute.snapshots.get",
    "compute.snapshots.list",
    "compute.snapshots.setLabels",
    "compute.subnetworks.get",
    "compute.subnetworks.list",
    "compute.zoneOperations.get",
    "compute.zones.get",
    "compute.zones.list",
    "compute.instances.setServiceAccount",
    "deploymentmanager.compositeTypes.get",
    "deploymentmanager.compositeTypes.list",
    "deploymentmanager.deployments.create",
    "deploymentmanager.deployments.delete",
    "deploymentmanager.deployments.get",
    "deploymentmanager.deployments.list",
    "deploymentmanager.manifests.get",
    "deploymentmanager.manifests.list",
    "deploymentmanager.operations.get",
    "deploymentmanager.operations.list",
    "deploymentmanager.resources.get",
    "deploymentmanager.resources.list",
    "deploymentmanager.typeProviders.get",
    "deploymentmanager.typeProviders.list",
    "deploymentmanager.types.get",
    "deploymentmanager.types.list",
    "logging.logEntries.list",
    "logging.privateLogEntries.list",
    "resourcemanager.projects.get",
    "storage.buckets.create",
    "storage.buckets.delete",
    "storage.buckets.get",
    "storage.buckets.list",
    "cloudkms.cryptoKeyVersions.useToEncrypt",
    "cloudkms.cryptoKeys.get",
    "cloudkms.cryptoKeys.list",
    "cloudkms.keyRings.list",
    "storage.buckets.update",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.list",
    "storage.objects.get",
    "storage.objects.list"
    ]
  }
