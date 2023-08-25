

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025259419089"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-230825025259419089"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-230825025259419089"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name     = "acctest-230825025259419089"
  topic_id = azurerm_servicebus_topic.test.id

  listen = true
  send   = false
  manage = false
}


resource "azurerm_servicebus_topic_authorization_rule" "import" {
  name     = azurerm_servicebus_topic_authorization_rule.test.name
  topic_id = azurerm_servicebus_topic_authorization_rule.test.topic_id

  listen = azurerm_servicebus_topic_authorization_rule.test.listen
  send   = azurerm_servicebus_topic_authorization_rule.test.send
  manage = azurerm_servicebus_topic_authorization_rule.test.manage
}
