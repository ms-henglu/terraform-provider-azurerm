
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "v2sn618n1vzkqoql20h6ur3as1bncxuncbl188ff2"
  token_secret = "h2qfidegyv92cf8gqprzwjd883bcak4ctaabsx960"
}
