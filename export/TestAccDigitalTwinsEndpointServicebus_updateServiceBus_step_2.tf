



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-211105035842573237"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-211105035842573237"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-211105035842573237"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-211105035842573237"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name                = "acctest-rule-211105035842573237"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  topic_name          = azurerm_servicebus_topic.test.name

  listen = false
  send   = true
  manage = false
}


resource "azurerm_servicebus_namespace" "test_alt" {
  name                = "acctestservicebusnamespace-alt-211105035842573237"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "basic"
}

resource "azurerm_servicebus_topic" "test_alt" {
  name                = "acctestservicebustopic-alt-211105035842573237"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_servicebus_topic_authorization_rule" "test_alt" {
  name                = "acctest-rule-alt-211105035842573237"
  namespace_name      = azurerm_servicebus_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  topic_name          = azurerm_servicebus_topic.test.name

  listen = false
  send   = true
  manage = false
}

resource "azurerm_digital_twins_endpoint_servicebus" "test" {
  name                                   = "acctest-EndpointSB-211105035842573237"
  digital_twins_id                       = azurerm_digital_twins_instance.test.id
  servicebus_primary_connection_string   = azurerm_servicebus_topic_authorization_rule.test_alt.primary_connection_string
  servicebus_secondary_connection_string = azurerm_servicebus_topic_authorization_rule.test_alt.secondary_connection_string
}
