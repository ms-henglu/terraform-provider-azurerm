
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "0vv0uk3vgps0dnlrzjjhx7du0fqajuc9yxe3bjdgn"
  token_secret = "6uth7cc47burnf9w31oh09lngbh7i1ucuwx3828gc"
}
