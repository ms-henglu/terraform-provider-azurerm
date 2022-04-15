

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415031106389725"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220415031106389725"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-220415031106389725"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name               = "acctestservicebussubscription-220415031106389725"
  topic_id           = azurerm_servicebus_topic.test.id
  max_delivery_count = 10
}


resource "azurerm_servicebus_subscription_rule" "test" {
  name            = "acctestservicebusrule-220415031106389725"
  subscription_id = azurerm_servicebus_subscription.test.id
  filter_type     = "SqlFilter"
  sql_filter      = "3=3"
}
