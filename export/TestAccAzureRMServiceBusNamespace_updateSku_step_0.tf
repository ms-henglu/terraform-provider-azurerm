
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916012012194898"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220916012012194898"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}
