
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034549172085"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-221021034549172085"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "forward_to" {
  name         = "acctestservicebusqueue-forward_to-221021034549172085"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_queue" "test" {
  name         = "acctestservicebusqueue-221021034549172085"
  namespace_id = azurerm_servicebus_namespace.test.id
  forward_to   = azurerm_servicebus_queue.forward_to.name
}
