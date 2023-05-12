
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-230512010322354197"
  location = "West Europe"
}


resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctestprofile-230512010322354197"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}
