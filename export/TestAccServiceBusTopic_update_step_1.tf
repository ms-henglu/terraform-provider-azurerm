
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211112021228936611"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211112021228936611"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                      = "acctestservicebustopic-211112021228936611"
  namespace_name            = azurerm_servicebus_namespace.test.name
  resource_group_name       = azurerm_resource_group.test.name
  enable_batched_operations = true
  enable_express            = true
}
