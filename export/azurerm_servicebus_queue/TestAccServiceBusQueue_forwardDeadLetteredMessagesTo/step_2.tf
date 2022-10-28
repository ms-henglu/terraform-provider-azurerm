
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172758488902"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-221028172758488902"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "forward_dl_messages_to" {
  name         = "acctestservicebusqueue-forward_dl_messages_to-221028172758488902"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_queue" "test" {
  name                              = "acctestservicebusqueue-221028172758488902"
  namespace_id                      = azurerm_servicebus_namespace.test.id
  forward_dead_lettered_messages_to = azurerm_servicebus_queue.forward_dl_messages_to.name
}
