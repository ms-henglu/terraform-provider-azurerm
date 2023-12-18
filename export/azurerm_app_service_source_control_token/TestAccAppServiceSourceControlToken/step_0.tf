
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "jobd3x7xsgxxxtw1hmyxuna9d7jqeigdwdpzdt6mv"
  token_secret = "og2qqo170nugrtzzz2pjtim1hq0yanpxdpwbfninb"
}
