



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-230127045339624272"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-230127045339624272"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-230127045339624272"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-230127045339624272"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  partition_count   = 2
  message_retention = 1
}

resource "azurerm_eventhub_authorization_rule" "test" {
  name                = "acctest-r230127045339624272"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = false
  send   = true
  manage = false
}


resource "azurerm_eventhub" "test_alt" {
  name                = "acctesteventhub-alt-230127045339624272"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name

  partition_count   = 2
  message_retention = 1
}

resource "azurerm_eventhub_authorization_rule" "test_alt" {
  name                = "acctest-r230127045339624272"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test_alt.name
  resource_group_name = azurerm_resource_group.test.name

  listen = false
  send   = true
  manage = false
}

resource "azurerm_digital_twins_endpoint_eventhub" "test" {
  name                                 = "acctest-EH-230127045339624272"
  digital_twins_id                     = azurerm_digital_twins_instance.test.id
  eventhub_primary_connection_string   = azurerm_eventhub_authorization_rule.test.primary_connection_string
  eventhub_secondary_connection_string = azurerm_eventhub_authorization_rule.test.secondary_connection_string
}
