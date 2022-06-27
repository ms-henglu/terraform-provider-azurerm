
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "wk114dvfb9q8y0bd3293ojy22xqjcgygniuq0p4su"
  token_secret = "m9et96zltv7gozgnqywt9iysx97w84kplsimf6jew"
}
