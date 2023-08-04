
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030650614007"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-230804030650614007"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  capacity            = 1
}

resource "azurerm_servicebus_queue" "test" {
  name                = "acctestservicebusqueue-230804030650614007"
  namespace_id        = azurerm_servicebus_namespace.test.id
  enable_partitioning = true
}
