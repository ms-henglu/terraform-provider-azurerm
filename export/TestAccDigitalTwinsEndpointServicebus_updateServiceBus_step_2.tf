



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-220811053212031227"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-220811053212031227"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220811053212031227"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-220811053212031227"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name     = "acctest-rule-220811053212031227"
  topic_id = azurerm_servicebus_topic.test.id

  listen = false
  send   = true
  manage = false
}


resource "azurerm_servicebus_namespace" "test_alt" {
  name                = "acctestservicebusnamespace-alt-220811053212031227"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

resource "azurerm_servicebus_topic" "test_alt" {
  name         = "acctestservicebustopic-alt-220811053212031227"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_topic_authorization_rule" "test_alt" {
  name     = "acctest-rule-alt-220811053212031227"
  topic_id = azurerm_servicebus_topic.test.id

  listen = false
  send   = true
  manage = false
}

resource "azurerm_digital_twins_endpoint_servicebus" "test" {
  name                                   = "acctest-EndpointSB-220811053212031227"
  digital_twins_id                       = azurerm_digital_twins_instance.test.id
  servicebus_primary_connection_string   = azurerm_servicebus_topic_authorization_rule.test_alt.primary_connection_string
  servicebus_secondary_connection_string = azurerm_servicebus_topic_authorization_rule.test_alt.secondary_connection_string
}
