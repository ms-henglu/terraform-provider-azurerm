
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044928384980"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211008044928384980"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "forward_dl_messages_to" {
  name                = "acctestservicebusqueue-forward_dl_messages_to-211008044928384980"
  resource_group_name = azurerm_resource_group.test.name
  namespace_name      = azurerm_servicebus_namespace.test.name
}

resource "azurerm_servicebus_queue" "test" {
  name                              = "acctestservicebusqueue-211008044928384980"
  resource_group_name               = azurerm_resource_group.test.name
  namespace_name                    = azurerm_servicebus_namespace.test.name
  forward_dead_lettered_messages_to = azurerm_servicebus_queue.forward_dl_messages_to.name
}
