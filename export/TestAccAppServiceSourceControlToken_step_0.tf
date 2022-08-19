
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "ept6musm187vebyaxosdal06xj8pzfezbzla2bny8"
  token_secret = "t0iei6t9j3ycf4qgij7l8sjkanhcn7l99vunfjqoj"
}
