
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "281xgpht4uwmyjc6jsiggfxs4o3kpd96ac70zxudm"
  token_secret = "8idur6phlsg3vsdcl68ovf8cwyjhsaa6ug0t3c23e"
}
