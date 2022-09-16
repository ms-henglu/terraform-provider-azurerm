
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916012012196718"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220916012012196718"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name             = "acctestservicebusqueue-220916012012196718"
  namespace_id     = azurerm_servicebus_namespace.test.id
  requires_session = true
}
