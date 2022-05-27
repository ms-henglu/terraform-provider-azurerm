
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "j07sbq3rgncj72sxrxc6vln2iu3wswjun8wth16fu"
  token_secret = "yla86nd4t489lpcj1ih46xxhacrape7ksmf6elv8u"
}
