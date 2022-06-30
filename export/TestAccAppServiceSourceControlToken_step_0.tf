
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "4uui28zq6m3ue42rjiep4gc9s3wggoecykytelrjl"
  token_secret = "s273x3296isoml1kqo8mkpcjs7ywi8z131exnlc02"
}
