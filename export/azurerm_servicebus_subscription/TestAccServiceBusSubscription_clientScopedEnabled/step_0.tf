
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025259411969"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestsbn-230825025259411969"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Premium"
  capacity            = 1
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-230825025259411969"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name                               = "_acctestsub-230825025259411969_"
  topic_id                           = azurerm_servicebus_topic.test.id
  max_delivery_count                 = 10
  client_scoped_subscription_enabled = true
  client_scoped_subscription {
    client_id                               = "123456"
    is_client_scoped_subscription_shareable = false
  }
}
