

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-231020041232738295"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-231020041232738295"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-231020041232738295"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_authorization_rule" "test" {
  name                = "acctest-231020041232738295"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = false
  send   = true
  manage = false
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestuai-231020041232738295"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_role_assignment" "test_azure_event_hubs_data_sender_user" {
  role_definition_name = "Azure Event Hubs Data Sender"
  scope                = azurerm_eventhub.test.id
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-231020041232738295"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "B1"
    capacity = "1"
  }

  tags = {
    purpose = "testing"
  }

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }

  depends_on = [
    azurerm_role_assignment.test_azure_event_hubs_data_sender_user,
  ]
}

resource "azurerm_role_assignment" "test_azure_event_hubs_data_sender_system" {
  role_definition_name = "Azure Event Hubs Data Sender"
  scope                = azurerm_eventhub.test.id
  principal_id         = azurerm_iothub.test.identity[0].principal_id
}


resource "azurerm_iothub_endpoint_eventhub" "test" {
  resource_group_name = azurerm_resource_group.test.name
  iothub_id           = azurerm_iothub.test.id
  name                = "acctest"

  authentication_type = "identityBased"
  endpoint_uri        = "sb://${azurerm_eventhub_namespace.test.name}.servicebus.windows.net"
  entity_path         = azurerm_eventhub.test.name

  depends_on = [
    azurerm_role_assignment.test_azure_event_hubs_data_sender_system,
  ]
}
