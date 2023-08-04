
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-cdn-afdx-230804025538101787"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctest-fdprofile-230804025538101787"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}


resource "azurerm_cdn_frontdoor_rule_set" "test" {
  name                     = "acctestfdruleset23080487"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
}
