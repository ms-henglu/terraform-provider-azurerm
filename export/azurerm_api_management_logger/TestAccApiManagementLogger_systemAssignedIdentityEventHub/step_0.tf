
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024407446682"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-240119024407446682"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-240119024407446682"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240119024407446682"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_api_management_logger" "test" {
  name                = "acctestapimnglogger-240119024407446682"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name

  eventhub {
    name         = azurerm_eventhub.test.name
    endpoint_uri = "${azurerm_eventhub_namespace.test.name}.servicebus.windows.net"
  }
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_eventhub.test.id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = azurerm_api_management.test.identity[0].principal_id
}
