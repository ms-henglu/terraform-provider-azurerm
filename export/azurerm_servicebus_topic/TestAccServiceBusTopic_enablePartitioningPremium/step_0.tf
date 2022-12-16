
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216014201209228"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-221216014201209228"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Premium"
  capacity            = 1
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-221216014201209228"
  namespace_id        = azurerm_servicebus_namespace.test.id
  enable_partitioning = false

  max_message_size_in_kilobytes = 102400
}
