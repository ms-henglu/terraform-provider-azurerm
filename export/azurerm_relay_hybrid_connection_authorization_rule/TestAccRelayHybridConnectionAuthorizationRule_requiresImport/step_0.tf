
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929065604740798"
  location = "West Europe"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctestrn-230929065604740798"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"
}

resource "azurerm_relay_hybrid_connection" "test" {
  name                 = "acctestrnhc-230929065604740798"
  resource_group_name  = azurerm_resource_group.test.name
  relay_namespace_name = azurerm_relay_namespace.test.name
}

resource "azurerm_relay_hybrid_connection_authorization_rule" "test" {
  name                   = "acctestrnak-230929065604740798"
  namespace_name         = azurerm_relay_namespace.test.name
  hybrid_connection_name = azurerm_relay_hybrid_connection.test.name
  resource_group_name    = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = false
}
