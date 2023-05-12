
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "e8q4vqn721fgal7r7n19mzg7v2gadr8jjdar7dwvl"
  token_secret = "8x1pnswmuaxf0x3rjiwicicj0ijrfpdbez2ynof37"
}
