
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072356025902"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211013072356025902"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                = "acctestservicebusqueue-211013072356025902"
  resource_group_name = azurerm_resource_group.test.name
  namespace_name      = azurerm_servicebus_namespace.test.name
  requires_session    = true
}
