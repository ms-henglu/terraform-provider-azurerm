

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-221111013200894261"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "accTestProfile-221111013200894261"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Premium_AzureFrontDoor"
}


resource "azurerm_cdn_frontdoor_firewall_policy" "test" {
  name                = "accTestWAF221111013200894261"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = azurerm_cdn_frontdoor_profile.test.sku_name
  mode                = "Prevention"
}
