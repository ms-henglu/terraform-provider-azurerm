
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "exyp7zxvicemv8rcmwsz0b9s6vdlum1oogz3gubvv"
  token_secret = "zr32w8ygxjh3qww7aue3wcv27gx0xkb778vvcryoh"
}
