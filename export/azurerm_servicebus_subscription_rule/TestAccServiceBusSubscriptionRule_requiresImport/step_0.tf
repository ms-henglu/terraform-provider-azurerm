

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034549189005"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-221021034549189005"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-221021034549189005"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name               = "acctestservicebussubscription-221021034549189005"
  topic_id           = azurerm_servicebus_topic.test.id
  max_delivery_count = 10
}


resource "azurerm_servicebus_subscription_rule" "test" {
  name            = "acctestservicebusrule-221021034549189005"
  subscription_id = azurerm_servicebus_subscription.test.id
  filter_type     = "SqlFilter"
  sql_filter      = "2=2"
}
