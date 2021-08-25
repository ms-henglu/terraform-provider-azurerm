
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "rgnjwv3ocdsif3tftcaezsmev0dbc4bc3ghthb692"
  token_secret = "448vrghldg0esplsy0hoy4n31onxa7kcd6wnxj9fy"
}
