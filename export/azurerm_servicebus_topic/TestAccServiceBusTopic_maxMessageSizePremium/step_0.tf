
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230602031047573304"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-230602031047573304"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Premium"
  capacity            = 1
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-230602031047573304"
  namespace_id        = azurerm_servicebus_namespace.test.id
  enable_partitioning = false

  max_message_size_in_kilobytes = 102400
}
