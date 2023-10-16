
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034700851747"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-231016034700851747"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Premium"
  capacity            = 1
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-231016034700851747"
  namespace_id        = azurerm_servicebus_namespace.test.id
  enable_partitioning = false

  max_message_size_in_kilobytes = 102400
}
