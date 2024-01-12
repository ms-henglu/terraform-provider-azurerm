

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-240112224622697106"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acc240112224622697106"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "acctestcont"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-240112224622697106"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name         = "acctest-240112224622697106"
  namespace_id = azurerm_servicebus_namespace.test.id

  enable_partitioning = true
}

resource "azurerm_servicebus_queue_authorization_rule" "test" {
  name     = "acctest-240112224622697106"
  queue_id = azurerm_servicebus_queue.test.id

  listen = false
  send   = true
  manage = false
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-240112224622697106"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name     = "acctest-240112224622697106"
  topic_id = azurerm_servicebus_topic.test.id

  listen = false
  send   = true
  manage = false
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-240112224622697106"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-240112224622697106"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_authorization_rule" "test" {
  name                = "acctest-240112224622697106"
  namespace_name      = azurerm_eventhub_namespace.test.name
  eventhub_name       = azurerm_eventhub.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = false
  send   = true
  manage = false
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestuai-240112224622697106"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_role_assignment" "test_storage_blob_data_contrib_user" {
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.test.id
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_role_assignment" "test_azure_service_bus_data_sender_queue_user" {
  role_definition_name = "Azure Service Bus Data Sender"
  scope                = azurerm_servicebus_queue.test.id
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_role_assignment" "test_azure_service_bus_data_sender_topic_user" {
  role_definition_name = "Azure Service Bus Data Sender"
  scope                = azurerm_servicebus_topic.test.id
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_role_assignment" "test_azure_event_hubs_data_sender_user" {
  role_definition_name = "Azure Event Hubs Data Sender"
  scope                = azurerm_eventhub.test.id
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_role_assignment" "test_storage_blob_data_contrib_system" {
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.test.id
  principal_id         = azurerm_iothub.test.identity[0].principal_id
}

resource "azurerm_role_assignment" "test_azure_service_bus_data_sender_queue_system" {
  role_definition_name = "Azure Service Bus Data Sender"
  scope                = azurerm_servicebus_queue.test.id
  principal_id         = azurerm_iothub.test.identity[0].principal_id
}

resource "azurerm_role_assignment" "test_azure_service_bus_data_sender_topic_system" {
  role_definition_name = "Azure Service Bus Data Sender"
  scope                = azurerm_servicebus_topic.test.id
  principal_id         = azurerm_iothub.test.identity[0].principal_id
}

resource "azurerm_role_assignment" "test_azure_event_hubs_data_sender_system" {
  role_definition_name = "Azure Event Hubs Data Sender"
  scope                = azurerm_eventhub.test.id
  principal_id         = azurerm_iothub.test.identity[0].principal_id
}



resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-240112224622697106"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  endpoint {
    type                = "AzureIotHub.StorageContainer"
    name                = "endpoint1"
    resource_group_name = azurerm_resource_group.test.name

    authentication_type = "identityBased"
    container_name      = azurerm_storage_container.test.name
    endpoint_uri        = azurerm_storage_account.test.primary_blob_endpoint
  }

  endpoint {
    type                = "AzureIotHub.ServiceBusQueue"
    name                = "endpoint2"
    resource_group_name = azurerm_resource_group.test.name

    authentication_type = "identityBased"
    endpoint_uri        = "sb://${azurerm_servicebus_namespace.test.name}.servicebus.windows.net"
    entity_path         = azurerm_servicebus_queue.test.name
  }

  endpoint {
    type                = "AzureIotHub.ServiceBusTopic"
    name                = "endpoint3"
    resource_group_name = azurerm_resource_group.test.name

    authentication_type = "identityBased"
    endpoint_uri        = "sb://${azurerm_servicebus_namespace.test.name}.servicebus.windows.net"
    entity_path         = azurerm_servicebus_topic.test.name
  }

  endpoint {
    type                = "AzureIotHub.EventHub"
    name                = "endpoint4"
    resource_group_name = azurerm_resource_group.test.name

    authentication_type = "identityBased"
    endpoint_uri        = "sb://${azurerm_eventhub_namespace.test.name}.servicebus.windows.net"
    entity_path         = azurerm_eventhub.test.name
  }

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }

  depends_on = [
    azurerm_role_assignment.test_storage_blob_data_contrib_user,
    azurerm_role_assignment.test_azure_service_bus_data_sender_queue_user,
    azurerm_role_assignment.test_azure_service_bus_data_sender_topic_user,
    azurerm_role_assignment.test_azure_event_hubs_data_sender_user,
  ]

  tags = {
    purpose = "testing"
  }
}
