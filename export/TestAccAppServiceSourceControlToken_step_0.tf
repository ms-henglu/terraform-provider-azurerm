
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "3qmy7veaxizirlzldxm66e22hxw2euov37m6d407b"
  token_secret = "hgam7t4bwgt46i0cm4cm33zwo4mz6w30fch8xus3v"
}
