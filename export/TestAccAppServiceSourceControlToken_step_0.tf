
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "z4ny8107t0gwtruvol9krvmoiv2x783vfsse3aaam"
  token_secret = "nhbhczlixlirerdencafqnigf9qti0306bcvtt1v0"
}
