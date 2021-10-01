

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001021223113913"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-211001021223113913"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_namespace_authorization_rule" "test" {
  name                = "acctest-211001021223113913"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = true
  send   = false
  manage = false
}


resource "azurerm_servicebus_namespace_authorization_rule" "import" {
  name                = azurerm_servicebus_namespace_authorization_rule.test.name
  namespace_name      = azurerm_servicebus_namespace_authorization_rule.test.namespace_name
  resource_group_name = azurerm_servicebus_namespace_authorization_rule.test.resource_group_name

  listen = azurerm_servicebus_namespace_authorization_rule.test.listen
  send   = azurerm_servicebus_namespace_authorization_rule.test.send
  manage = azurerm_servicebus_namespace_authorization_rule.test.manage
}
