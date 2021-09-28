
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "kd1gw3zkb1sdskp1nb9aj3qxb7z2afzzat3cgs7z9"
  token_secret = "bflt1nfjocsk8n1l7whkjzepaobfblvva7b29eosx"
}
