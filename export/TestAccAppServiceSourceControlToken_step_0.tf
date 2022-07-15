
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "83en1w8gvw024or0kg21v4obbs32bauzxg217yd20"
  token_secret = "cnb0lozhlc1n12izu8q28t4fgjtqbc3yh834q2dgd"
}
