
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505051140603537"
  location = "West Europe"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctestrn-230505051140603537"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"
}

resource "azurerm_relay_hybrid_connection" "test" {
  name                 = "acctestrnhc-230505051140603537"
  resource_group_name  = azurerm_resource_group.test.name
  relay_namespace_name = azurerm_relay_namespace.test.name
}

resource "azurerm_relay_hybrid_connection_authorization_rule" "test" {
  name                   = "acctestrnak-230505051140603537"
  namespace_name         = azurerm_relay_namespace.test.name
  hybrid_connection_name = azurerm_relay_hybrid_connection.test.name
  resource_group_name    = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = false
}
