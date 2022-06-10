



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-220610022517101127"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-220610022517101127"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-220610022517101127"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-220610022517101127"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name     = "acctest-rule-220610022517101127"
  topic_id = azurerm_servicebus_topic.test.id

  listen = false
  send   = true
  manage = false
}


resource "azurerm_storage_account" "test" {
  name                     = "acctestacc7lvp3"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_digital_twins_endpoint_servicebus" "test" {
  name                                   = "acctest-EndpointSB-220610022517101127"
  digital_twins_id                       = azurerm_digital_twins_instance.test.id
  servicebus_primary_connection_string   = azurerm_servicebus_topic_authorization_rule.test.primary_connection_string
  servicebus_secondary_connection_string = azurerm_servicebus_topic_authorization_rule.test.secondary_connection_string
}
