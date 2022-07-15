
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-220715004212207745"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctest-cdnfdprofile-220715004212207745"
  sku_name            = "Standard_AzureFrontDoor"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_cdn_frontdoor_endpoint" "test" {
  name                     = "acctest-cdnfdendpoint-220715004212207745"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
}
