
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311033058817798"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                         = "acctestservicebusnamespace-240311033058817798"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  sku                          = "Premium"
  premium_messaging_partitions = 1
  capacity                     = 1
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-240311033058817798"
  namespace_id        = azurerm_servicebus_namespace.test.id
  enable_partitioning = false

  max_message_size_in_kilobytes = 102400
}
