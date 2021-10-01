

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001224452087230"
  location = "West Europe"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctestrn-211001224452087230"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"
}

resource "azurerm_relay_hybrid_connection" "test" {
  name                 = "acctestrnhc-211001224452087230"
  resource_group_name  = azurerm_resource_group.test.name
  relay_namespace_name = azurerm_relay_namespace.test.name
}

resource "azurerm_relay_hybrid_connection_authorization_rule" "test" {
  name                   = "acctestrnak-211001224452087230"
  namespace_name         = azurerm_relay_namespace.test.name
  hybrid_connection_name = azurerm_relay_hybrid_connection.test.name
  resource_group_name    = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = false
}


resource "azurerm_relay_hybrid_connection_authorization_rule" "import" {
  name                   = azurerm_relay_hybrid_connection_authorization_rule.test.name
  namespace_name         = azurerm_relay_hybrid_connection_authorization_rule.test.namespace_name
  hybrid_connection_name = azurerm_relay_hybrid_connection_authorization_rule.test.hybrid_connection_name
  resource_group_name    = azurerm_relay_hybrid_connection_authorization_rule.test.resource_group_name

  listen = azurerm_relay_hybrid_connection_authorization_rule.test.listen
  send   = azurerm_relay_hybrid_connection_authorization_rule.test.send
  manage = azurerm_relay_hybrid_connection_authorization_rule.test.manage
}
