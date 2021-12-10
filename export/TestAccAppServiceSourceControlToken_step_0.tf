
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "eqouegtt69ju3uzwxfg9nyzm07vfcexiguts3njpg"
  token_secret = "hsf7d3vz0yhc3p8iytiatjz2ylq6wpah39ejghrhc"
}
