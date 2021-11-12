
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "09zz10v7bve1j2au2ckchc6kppr9ajelugano2hqw"
  token_secret = "n7g9kb3ykds3vobczdadfuxfnyyndophpk7kdi24q"
}
