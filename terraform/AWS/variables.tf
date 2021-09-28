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
