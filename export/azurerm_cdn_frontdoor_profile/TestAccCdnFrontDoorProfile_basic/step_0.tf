
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-230804025538094571"
  location = "West Europe"
}


resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctestprofile-230804025538094571"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}
