
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042752032320"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220712042752032320"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Premium"
  capacity            = 1
}

resource "azurerm_servicebus_queue" "test" {
  name                = "acctestservicebusqueue-220712042752032320"
  namespace_id        = azurerm_servicebus_namespace.test.id
  enable_partitioning = false
  enable_express      = false

  max_message_size_in_kilobytes = 102400
}
