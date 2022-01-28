
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "pgxkcy8bz6abc4vx8v9qwlrrgbpj0ymo4c0uzwfpg"
  token_secret = "3bntiyaudejoq4gaylzbrsrnqze8f0nd8ugy64hmz"
}
