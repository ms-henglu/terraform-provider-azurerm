
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "iquba0xmdh8aywnvd844r67luh4fe6eyuanjul87q"
  token_secret = "20musc0uqef7ozmjf4p3z3p7v8pw1dfld7ugkqcyt"
}
