
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603005308730607"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220603005308730607"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "forward_to" {
  name         = "acctestservicebusqueue-forward_to-220603005308730607"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_queue" "test" {
  name         = "acctestservicebusqueue-220603005308730607"
  namespace_id = azurerm_servicebus_namespace.test.id
  forward_to   = azurerm_servicebus_queue.forward_to.name
}
