
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-230512010322354379"
  location = "West Europe"
}


resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctestprofile-230512010322354379"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Premium_AzureFrontDoor"

  response_timeout_seconds = 120

  tags = {
    ENV = "Production"
  }
}
