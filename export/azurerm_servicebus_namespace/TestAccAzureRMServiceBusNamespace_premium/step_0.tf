
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315124023682462"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                         = "acctestservicebusnamespace-240315124023682462"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  sku                          = "Premium"
  capacity                     = 4
  premium_messaging_partitions = 1
}
