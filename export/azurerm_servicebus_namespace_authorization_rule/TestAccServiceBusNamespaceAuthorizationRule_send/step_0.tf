
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014235123845"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-221111014235123845"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_namespace_authorization_rule" "test" {
  name         = "acctest-221111014235123845"
  namespace_id = azurerm_servicebus_namespace.test.id

  listen = false
  send   = true
  manage = false
}
