

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034700849980"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-231016034700849980"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_namespace_authorization_rule" "test" {
  name         = "acctest-231016034700849980"
  namespace_id = azurerm_servicebus_namespace.test.id

  listen = true
  send   = false
  manage = false
}


resource "azurerm_servicebus_namespace_authorization_rule" "import" {
  name         = azurerm_servicebus_namespace_authorization_rule.test.name
  namespace_id = azurerm_servicebus_namespace_authorization_rule.test.namespace_id

  listen = azurerm_servicebus_namespace_authorization_rule.test.listen
  send   = azurerm_servicebus_namespace_authorization_rule.test.send
  manage = azurerm_servicebus_namespace_authorization_rule.test.manage
}
