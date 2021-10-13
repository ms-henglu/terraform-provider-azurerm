
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072356036304"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211013072356036304"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Premium"
  capacity            = 1
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-211013072356036304"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  enable_partitioning = false
}
