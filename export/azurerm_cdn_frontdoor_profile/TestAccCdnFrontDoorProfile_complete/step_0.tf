
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-230804025538091830"
  location = "West Europe"
}


resource "azurerm_cdn_frontdoor_profile" "test" {
  name                     = "acctestprofile-230804025538091830"
  resource_group_name      = azurerm_resource_group.test.name
  response_timeout_seconds = 240
  sku_name                 = "Premium_AzureFrontDoor"

  tags = {
    ENV = "Test"
  }
}
