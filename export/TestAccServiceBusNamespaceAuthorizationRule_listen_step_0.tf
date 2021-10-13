
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072356010029"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-211013072356010029"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_namespace_authorization_rule" "test" {
  name                = "acctest-211013072356010029"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = false
  manage = false
}
