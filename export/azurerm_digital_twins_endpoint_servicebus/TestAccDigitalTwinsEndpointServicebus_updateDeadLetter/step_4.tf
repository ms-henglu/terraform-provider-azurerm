



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-221021034044030411"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-221021034044030411"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_servicebus_namespace" "test" {
  name                = "acctestservicebusnamespace-221021034044030411"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-221021034044030411"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name     = "acctest-rule-221021034044030411"
  topic_id = azurerm_servicebus_topic.test.id

  listen = false
  send   = true
  manage = false
}


resource "azurerm_storage_account" "test" {
  name                     = "acctestaccohtlq"
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
  name                                   = "acctest-EndpointSB-221021034044030411"
  digital_twins_id                       = azurerm_digital_twins_instance.test.id
  servicebus_primary_connection_string   = azurerm_servicebus_topic_authorization_rule.test.primary_connection_string
  servicebus_secondary_connection_string = azurerm_servicebus_topic_authorization_rule.test.secondary_connection_string
}
