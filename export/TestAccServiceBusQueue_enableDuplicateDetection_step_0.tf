
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916012012190074"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220916012012190074"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name         = "acctestservicebusqueue-220916012012190074"
  namespace_id = azurerm_servicebus_namespace.test.id
}
