
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-240119024619124931"
  location = "West Europe"
}


resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctestprofile-240119024619124931"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Premium_AzureFrontDoor"

  response_timeout_seconds = 120

  tags = {
    ENV = "Production"
  }
}
