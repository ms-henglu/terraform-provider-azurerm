
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311033058794432"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                         = "acctestservicebusnamespace-240311033058794432"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  sku                          = "Premium"
  premium_messaging_partitions = 1
  capacity                     = 1
  zone_redundant               = true
}
