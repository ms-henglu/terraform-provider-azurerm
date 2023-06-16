
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "e3nxh6y1bsa9n0wuj69upk77ompvywn1qxzyjj41p"
  token_secret = "whyxfij0g4k7e4jzrmwegdw0j4vnri1kqzoq79ucc"
}
