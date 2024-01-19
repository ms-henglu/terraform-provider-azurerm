
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-cdn-afdx-240119024619119535"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctest-cdnfdprofile-240119024619119535"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}


resource "azurerm_cdn_frontdoor_origin_group" "test" {
  name                     = "acctest-origingroup-240119024619119535"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id

  load_balancing {
  }
}
