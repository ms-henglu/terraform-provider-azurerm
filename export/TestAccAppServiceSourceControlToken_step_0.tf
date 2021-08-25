
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "sryftzl7twyfni8lw10opqpo8udc0wlnak9schkte"
  token_secret = "w9kmvbfacsp0xgigwaxjck4xc7wqmlqdko9b8mvqx"
}
