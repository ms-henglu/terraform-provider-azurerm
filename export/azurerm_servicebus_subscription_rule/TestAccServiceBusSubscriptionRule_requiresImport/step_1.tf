


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313021857966315"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-230313021857966315"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-230313021857966315"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name               = "acctestservicebussubscription-230313021857966315"
  topic_id           = azurerm_servicebus_topic.test.id
  max_delivery_count = 10
}


resource "azurerm_servicebus_subscription_rule" "test" {
  name            = "acctestservicebusrule-230313021857966315"
  subscription_id = azurerm_servicebus_subscription.test.id
  filter_type     = "SqlFilter"
  sql_filter      = "2=2"
}


resource "azurerm_servicebus_subscription_rule" "import" {
  name            = azurerm_servicebus_subscription_rule.test.name
  subscription_id = azurerm_servicebus_subscription_rule.test.subscription_id
  filter_type     = azurerm_servicebus_subscription_rule.test.filter_type
  sql_filter      = azurerm_servicebus_subscription_rule.test.sql_filter
}
