
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311033058790504"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                         = "acctestservicebusnamespace-240311033058790504"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  sku                          = "Premium"
  premium_messaging_partitions = 1
  capacity                     = 1
}

resource "azurerm_servicebus_queue" "test" {
  name                = "acctestservicebusqueue-240311033058790504"
  namespace_id        = azurerm_servicebus_namespace.test.id
  enable_partitioning = false
  enable_express      = false

  max_message_size_in_kilobytes = 102400
}
