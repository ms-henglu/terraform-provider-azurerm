
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-cdn-afdx-220916011152216577"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctest-cdnfdprofile-220916011152216577"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}


resource "azurerm_cdn_frontdoor_origin_group" "test" {
  name                     = "acctest-origingroup-220916011152216577"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id

  load_balancing {
  }
}
