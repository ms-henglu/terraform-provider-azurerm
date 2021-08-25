
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "7pns07a8nkmoow103aiudylbd611m70nbcj1xquaz"
  token_secret = "o01y88txb0i2cuqobarwsomtnb6x67sbmg9rfv1fc"
}
