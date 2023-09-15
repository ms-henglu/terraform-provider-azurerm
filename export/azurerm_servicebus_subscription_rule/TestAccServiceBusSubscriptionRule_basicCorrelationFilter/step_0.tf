

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024150224421"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-230915024150224421"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-230915024150224421"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name               = "acctestservicebussubscription-230915024150224421"
  topic_id           = azurerm_servicebus_topic.test.id
  max_delivery_count = 10
}


resource "azurerm_servicebus_subscription_rule" "test" {
  name            = "acctestservicebusrule-230915024150224421"
  subscription_id = azurerm_servicebus_subscription.test.id
  filter_type     = "CorrelationFilter"

  correlation_filter {
    correlation_id      = "test_correlation_id"
    message_id          = "test_message_id"
    to                  = "test_to"
    reply_to            = "test_reply_to"
    label               = "test_label"
    session_id          = "test_session_id"
    reply_to_session_id = "test_reply_to_session_id"
    content_type        = "test_content_type"
  }
}
