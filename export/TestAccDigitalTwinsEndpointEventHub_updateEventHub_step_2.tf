



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-220107064006023287"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-220107064006023287"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-220107064006023287"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-220107064006023287"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  partition_count   = 2
  message_retention = 1
}

resource "azurerm_eventhub_authorization_rule" "test" {
  name                = "acctest-r220107064006023287"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = false
  send   = true
  manage = false
}


resource "azurerm_eventhub" "test_alt" {
  name                = "acctesteventhub-alt-220107064006023287"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  partition_count   = 2
  message_retention = 1
}

resource "azurerm_eventhub_authorization_rule" "test_alt" {
  name                = "acctest-r220107064006023287"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test_alt.name
  resource_group_name = azurerm_resource_group.test.name

  listen = false
  send   = true
  manage = false
}

resource "azurerm_digital_twins_endpoint_eventhub" "test" {
  name                                 = "acctest-EH-220107064006023287"
  digital_twins_id                     = azurerm_digital_twins_instance.test.id
  eventhub_primary_connection_string   = azurerm_eventhub_authorization_rule.test_alt.primary_connection_string
  eventhub_secondary_connection_string = azurerm_eventhub_authorization_rule.test_alt.secondary_connection_string
}
