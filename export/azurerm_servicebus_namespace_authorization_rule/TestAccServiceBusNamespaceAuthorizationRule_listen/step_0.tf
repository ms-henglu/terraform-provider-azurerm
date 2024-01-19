
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025804607425"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-240119025804607425"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_namespace_authorization_rule" "test" {
  name         = "acctest-240119025804607425"
  namespace_id = azurerm_servicebus_namespace.test.id

  listen = true
  send   = false
  manage = false
}
