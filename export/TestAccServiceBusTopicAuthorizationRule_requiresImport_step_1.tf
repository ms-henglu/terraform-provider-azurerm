

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029020200366777"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-211029020200366777"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-211029020200366777"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name                = "acctest-211029020200366777"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  topic_name          = azurerm_servicebus_topic.test.name

  listen = true
  send   = false
  manage = false
}


resource "azurerm_servicebus_topic_authorization_rule" "import" {
  name                = azurerm_servicebus_topic_authorization_rule.test.name
  namespace_name      = azurerm_servicebus_topic_authorization_rule.test.namespace_name
  resource_group_name = azurerm_servicebus_topic_authorization_rule.test.resource_group_name
  topic_name          = azurerm_servicebus_topic_authorization_rule.test.topic_name

  listen = azurerm_servicebus_topic_authorization_rule.test.listen
  send   = azurerm_servicebus_topic_authorization_rule.test.send
  manage = azurerm_servicebus_topic_authorization_rule.test.manage
}
