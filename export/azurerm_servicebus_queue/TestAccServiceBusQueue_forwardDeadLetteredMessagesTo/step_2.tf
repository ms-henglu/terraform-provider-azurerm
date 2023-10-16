
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034700853668"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-231016034700853668"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "forward_dl_messages_to" {
  name         = "acctestservicebusqueue-forward_dl_messages_to-231016034700853668"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_queue" "test" {
  name                              = "acctestservicebusqueue-231016034700853668"
  namespace_id                      = azurerm_servicebus_namespace.test.id
  forward_dead_lettered_messages_to = azurerm_servicebus_queue.forward_dl_messages_to.name
}
