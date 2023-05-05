
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "pz37efbtkgslfskeyqo7j6ykh4ioz3gh83inheuwi"
  token_secret = "h1t442dzhf4py1l0cb3jbgkimkewyh34lu403dp8o"
}
