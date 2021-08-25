
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "q12s4ka8vhuk7soigalfh19reoey1ls2jduveik8g"
  token_secret = "akio204mlaqvt4a9nc3kefiflprezcgr7lxv6zgu3"
}
