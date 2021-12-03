
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "7s1e0cfaqugcy13zu2juwzpmy6xuqaygos37gk4aa"
  token_secret = "fxbtct4zd3yahgsocyh2dfdoab90wvnle96b2zqiy"
}
