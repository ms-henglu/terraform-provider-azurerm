
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315124023700122"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                         = "acctestsbn-240315124023700122"
  location                     = "${azurerm_resource_group.test.location}"
  resource_group_name          = "${azurerm_resource_group.test.name}"
  sku                          = "Premium"
  premium_messaging_partitions = 1
  capacity                     = 1
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-240315124023700122"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name                               = "_acctestsub-240315124023700122_"
  topic_id                           = azurerm_servicebus_topic.test.id
  max_delivery_count                 = 10
  client_scoped_subscription_enabled = true
  client_scoped_subscription {
    client_id                               = "123456"
    is_client_scoped_subscription_shareable = false
  }
}
