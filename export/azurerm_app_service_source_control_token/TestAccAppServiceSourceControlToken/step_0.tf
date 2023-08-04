
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "7n0ma7rck0gk2sbd6lujke4i16cgbuc3a78gbzwts"
  token_secret = "r4bxt0uw7y09g3vzt0ylmg90nvilwng9fsheazvtj"
}
