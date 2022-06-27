



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-220627131847588022"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-220627131847588022"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220627131847588022"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-220627131847588022"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name                = "acctest-rule-220627131847588022"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  topic_name          = azurerm_servicebus_topic.test.name

  listen = false
  send   = true
  manage = false
}


resource "azurerm_digital_twins_endpoint_servicebus" "test" {
  name                                   = "acctest-EndpointSB-220627131847588022"
  digital_twins_id                       = azurerm_digital_twins_instance.test.id
  servicebus_primary_connection_string   = azurerm_servicebus_topic_authorization_rule.test.primary_connection_string
  servicebus_secondary_connection_string = azurerm_servicebus_topic_authorization_rule.test.secondary_connection_string
}
