
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "4e6n6l47lgdbk7foiztoqnz2cnz29s4iw8apxavit"
  token_secret = "idnrhhlkirpix1oxvo8ypy3i2ybt42ggq0us39jmd"
}
