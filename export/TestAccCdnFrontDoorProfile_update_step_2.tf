
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cdn-afdx-220603004616545393"
  location = "West Europe"
}


resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctest-c-220603004616545393"
  resource_group_name = azurerm_resource_group.test.name

  response_timeout_seconds = 120
  sku_name                 = "Premium_AzureFrontDoor"

  tags = {
    ENV = "Production"
  }
}
