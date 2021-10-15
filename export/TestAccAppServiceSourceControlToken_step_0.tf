
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "s2fgv7di1b0741ae0gtehu2c6wx6wuch6p78d3jfw"
  token_secret = "bmvv8xvxtwrbp7xs4j7potw370z89bnt724qxhe9k"
}
