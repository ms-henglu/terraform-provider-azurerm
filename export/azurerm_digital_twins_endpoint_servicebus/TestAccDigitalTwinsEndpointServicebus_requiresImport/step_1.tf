




provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-230922061037656379"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-230922061037656379"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-230922061037656379"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-230922061037656379"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name     = "acctest-rule-230922061037656379"
  topic_id = azurerm_servicebus_topic.test.id

  listen = false
  send   = true
  manage = false
}


resource "azurerm_digital_twins_endpoint_servicebus" "test" {
  name                                   = "acctest-EndpointSB-230922061037656379"
  digital_twins_id                       = azurerm_digital_twins_instance.test.id
  servicebus_primary_connection_string   = azurerm_servicebus_topic_authorization_rule.test.primary_connection_string
  servicebus_secondary_connection_string = azurerm_servicebus_topic_authorization_rule.test.secondary_connection_string
}


resource "azurerm_digital_twins_endpoint_servicebus" "import" {
  name                                   = azurerm_digital_twins_endpoint_servicebus.test.name
  digital_twins_id                       = azurerm_digital_twins_endpoint_servicebus.test.digital_twins_id
  servicebus_primary_connection_string   = azurerm_digital_twins_endpoint_servicebus.test.servicebus_primary_connection_string
  servicebus_secondary_connection_string = azurerm_digital_twins_endpoint_servicebus.test.servicebus_secondary_connection_string
}
