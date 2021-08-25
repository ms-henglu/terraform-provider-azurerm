


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825043240841028"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-210825043240841028"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-210825043240841028"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_servicebus_subscription" "test" {
  name                = "acctestservicebussubscription-210825043240841028"
  namespace_name      = azurerm_servicebus_namespace.test.name
  topic_name          = azurerm_servicebus_topic.test.name
  resource_group_name = azurerm_resource_group.test.name
  max_delivery_count  = 10
}


resource "azurerm_servicebus_subscription_rule" "test" {
  name                = "acctestservicebusrule-210825043240841028"
  namespace_name      = azurerm_servicebus_namespace.test.name
  topic_name          = azurerm_servicebus_topic.test.name
  subscription_name   = azurerm_servicebus_subscription.test.name
  resource_group_name = azurerm_resource_group.test.name
  filter_type         = "SqlFilter"
  sql_filter          = "2=2"
}


resource "azurerm_servicebus_subscription_rule" "import" {
  name                = azurerm_servicebus_subscription_rule.test.name
  namespace_name      = azurerm_servicebus_subscription_rule.test.namespace_name
  topic_name          = azurerm_servicebus_subscription_rule.test.topic_name
  subscription_name   = azurerm_servicebus_subscription_rule.test.subscription_name
  resource_group_name = azurerm_servicebus_subscription_rule.test.resource_group_name
  filter_type         = azurerm_servicebus_subscription_rule.test.filter_type
  sql_filter          = azurerm_servicebus_subscription_rule.test.sql_filter
}
