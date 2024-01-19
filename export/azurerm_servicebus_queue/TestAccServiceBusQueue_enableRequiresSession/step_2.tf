
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025804610942"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-240119025804610942"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name             = "acctestservicebusqueue-240119025804610942"
  namespace_id     = azurerm_servicebus_namespace.test.id
  requires_session = true
}
