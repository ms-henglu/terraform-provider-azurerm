
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072523065236"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-231218072523065236"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-231218072523065236"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name               = "_acctestservicebussubscription-231218072523065236_"
  topic_id           = azurerm_servicebus_topic.test.id
  max_delivery_count = 10
	
}
