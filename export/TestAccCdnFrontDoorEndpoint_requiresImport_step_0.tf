
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-220916011152213493"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctest-cdnfdprofile-220916011152213493"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}


resource "azurerm_cdn_frontdoor_endpoint" "test" {
  name                     = "acctest-cdnfdendpoint-220916011152213493"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
}
