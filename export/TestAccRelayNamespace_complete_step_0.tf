
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003216633797"
  location = "West Europe"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctestrn-220826003216633797"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"

  tags = {
    Hello = "World"
  }
}
