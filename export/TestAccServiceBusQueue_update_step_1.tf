
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211112021228917471"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211112021228917471"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                      = "acctestservicebusqueue-211112021228917471"
  resource_group_name       = azurerm_resource_group.test.name
  namespace_name            = azurerm_servicebus_namespace.test.name
  enable_express            = true
  max_size_in_megabytes     = 2048
  enable_batched_operations = false
}
