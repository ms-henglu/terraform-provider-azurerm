
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114064632967996"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220114064632967996"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "forward_to" {
  name         = "acctestservicebusqueue-forward_to-220114064632967996"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_queue" "test" {
  name         = "acctestservicebusqueue-220114064632967996"
  namespace_id = azurerm_servicebus_namespace.test.id
  forward_to   = azurerm_servicebus_queue.forward_to.name
}
