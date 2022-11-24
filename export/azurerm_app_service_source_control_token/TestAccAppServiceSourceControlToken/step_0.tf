
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "h84av1t9bq9thb8uhouwbecy3z6dmzdtfhxxg1egc"
  token_secret = "vh0r70d9lfku431gfklapwpzl0giuj6j8fr8sbtqk"
}
