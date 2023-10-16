

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034700853854"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-231016034700853854"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-231016034700853854"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_subscription" "test" {
  name               = "acctestservicebussubscription-231016034700853854"
  topic_id           = azurerm_servicebus_topic.test.id
  max_delivery_count = 10
}


resource "azurerm_servicebus_subscription_rule" "test" {
  name            = "acctestservicebusrule-231016034700853854"
  subscription_id = azurerm_servicebus_subscription.test.id
  filter_type     = "SqlFilter"
  sql_filter      = "2=2"
}
