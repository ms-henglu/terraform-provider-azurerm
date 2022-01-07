
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107064655324997"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220107064655324997"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-220107064655324997"
  namespace_name      = "${azurerm_servicebus_namespace.test.name}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_servicebus_subscription" "test" {
  name                                 = "_acctestservicebussubscription-220107064655324997_"
  namespace_name                       = "${azurerm_servicebus_namespace.test.name}"
  topic_name                           = "${azurerm_servicebus_topic.test.name}"
  resource_group_name                  = "${azurerm_resource_group.test.name}"
  max_delivery_count                   = 10
  auto_delete_on_idle                  = "PT5M"
  lock_duration                        = "PT1M"
  dead_lettering_on_message_expiration = true
	
}

