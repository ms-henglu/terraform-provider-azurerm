
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030650613674"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-230804030650613674"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name             = "acctestservicebusqueue-230804030650613674"
  namespace_id     = azurerm_servicebus_namespace.test.id
  requires_session = true
}
