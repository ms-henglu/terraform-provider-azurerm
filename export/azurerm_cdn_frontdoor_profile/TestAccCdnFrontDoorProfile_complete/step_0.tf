
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-231016033515752240"
  location = "West Europe"
}


resource "azurerm_cdn_frontdoor_profile" "test" {
  name                     = "acctestprofile-231016033515752240"
  resource_group_name      = azurerm_resource_group.test.name
  response_timeout_seconds = 240
  sku_name                 = "Premium_AzureFrontDoor"

  tags = {
    ENV = "Test"
  }
}
