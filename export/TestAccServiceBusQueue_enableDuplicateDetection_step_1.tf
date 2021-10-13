
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072356028005"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211013072356028005"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                         = "acctestservicebusqueue-211013072356028005"
  resource_group_name          = azurerm_resource_group.test.name
  namespace_name               = azurerm_servicebus_namespace.test.name
  requires_duplicate_detection = true
}
