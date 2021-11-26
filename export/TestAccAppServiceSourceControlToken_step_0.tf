
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "w8pko4agyt1bhods0vnrd82mvbuqq00ajp2qxga72"
  token_secret = "g1si18oql8x3a7130dafcvw1sqcqh3phgey36u4kk"
}
