

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-231016033515744572"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctest-cdnfdprofile-231016033515744572"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}


resource "azurerm_cdn_frontdoor_endpoint" "test" {
  name                     = "acctest-cdnfdendpoint-231016033515744572"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
}


resource "azurerm_cdn_frontdoor_endpoint" "import" {
  name                     = azurerm_cdn_frontdoor_endpoint.test.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_endpoint.test.cdn_frontdoor_profile_id
}
