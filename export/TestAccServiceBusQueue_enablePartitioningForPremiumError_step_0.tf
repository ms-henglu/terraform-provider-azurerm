
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916012012193886"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220916012012193886"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  capacity            = 1
}

resource "azurerm_servicebus_queue" "test" {
  name                = "acctestservicebusqueue-220916012012193886"
  namespace_id        = azurerm_servicebus_namespace.test.id
  enable_partitioning = true
}
