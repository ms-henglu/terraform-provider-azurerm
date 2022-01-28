
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "ynpg2g7uteosixarcnplmsmix3urcqls3tcar60mk"
  token_secret = "rixvqny1m80u98cnucu1jzloapx3y6jzgtpmx3a0c"
}
