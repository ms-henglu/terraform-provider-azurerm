
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "2sf33rzrl64m0h4xoqcb2ekfxqfh16t2nda4ot4ae"
  token_secret = "zuuvdwxqfb78s44shqv0d03ivnkac29pftndg9asq"
}
