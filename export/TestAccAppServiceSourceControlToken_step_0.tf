
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "js8pqej7mumo7ugyvnxq3dv339ojqzstrvsc0rm3u"
  token_secret = "641wernggzg9cc4l7imha2jfl3dojmubn6l8as388"
}
