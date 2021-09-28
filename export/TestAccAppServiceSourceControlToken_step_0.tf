
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "rcsl7tywzddt07us2eje2sh8jat4s34ss7bl60vc7"
  token_secret = "px7h1xplvxm6sxhkgasj8qtyz6y3y69ryokmjbbsu"
}
