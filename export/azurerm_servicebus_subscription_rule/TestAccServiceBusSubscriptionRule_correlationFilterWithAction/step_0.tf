

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034700859462"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-231016034700859462"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-231016034700859462"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name               = "acctestservicebussubscription-231016034700859462"
  topic_id           = azurerm_servicebus_topic.test.id
  max_delivery_count = 10
}


resource "azurerm_servicebus_subscription_rule" "test" {
  name            = "acctestservicebusrule-231016034700859462"
  subscription_id = azurerm_servicebus_subscription.test.id
  action          = "SET Test='true'"
  filter_type     = "CorrelationFilter"

  correlation_filter {
    correlation_id = "test_correlation_id"
    message_id     = "test_message_id"
  }
}
