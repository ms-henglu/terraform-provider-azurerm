
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072356029907"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211013072356029907"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                = "acctestservicebusqueue-211013072356029907"
  resource_group_name = azurerm_resource_group.test.name
  namespace_name      = azurerm_servicebus_namespace.test.name
  status              = "Disabled"
}
