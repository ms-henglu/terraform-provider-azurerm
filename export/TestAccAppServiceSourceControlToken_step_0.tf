
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "bawabqder4pa4mgu9set3bngwf47muxo1il28684r"
  token_secret = "6ojxf0e3caqzq9zrxs1qkvjnr2gmr3n6s06icpr94"
}
