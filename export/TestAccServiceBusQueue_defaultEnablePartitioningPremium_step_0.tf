
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072356021467"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211013072356021467"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "premium"
  capacity            = 1
}

resource "azurerm_servicebus_queue" "test" {
  name                = "acctestservicebusqueue-211013072356021467"
  resource_group_name = azurerm_resource_group.test.name
  namespace_name      = azurerm_servicebus_namespace.test.name
  enable_partitioning = false
  enable_express      = false
}
