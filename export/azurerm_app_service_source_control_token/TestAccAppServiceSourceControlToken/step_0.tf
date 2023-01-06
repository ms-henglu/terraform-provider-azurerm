
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "1u6s0elm1anfi4t37kvsopt3yyrlqyk1i917i4fei"
  token_secret = "lgzpz4rlysdpnmzvejs70bhc9dwr3sqajbgbtqw9n"
}
