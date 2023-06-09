

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609091918237123"
  location = "West Europe"
}

resource "azurerm_relay_namespace" "test" {
  name                = "acctestrn-230609091918237123"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Standard"
}

resource "azurerm_relay_namespace_authorization_rule" "test" {
  name                = "acctestrnak-230609091918237123"
  namespace_name      = azurerm_relay_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = true
  manage = false
}


resource "azurerm_relay_namespace_authorization_rule" "import" {
  name                = azurerm_relay_namespace_authorization_rule.test.name
  namespace_name      = azurerm_relay_namespace_authorization_rule.test.namespace_name
  resource_group_name = azurerm_relay_namespace_authorization_rule.test.resource_group_name

  listen = azurerm_relay_namespace_authorization_rule.test.listen
  send   = azurerm_relay_namespace_authorization_rule.test.send
  manage = azurerm_relay_namespace_authorization_rule.test.manage
}
