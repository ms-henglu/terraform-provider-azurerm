
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "kyq1v7s6t2y27c9ixwv6vcekd44r61c1mj8hyqz9i"
  token_secret = "zng704ypbr6ykmqihsfztm37jbpuncl8atozlkvgi"
}
