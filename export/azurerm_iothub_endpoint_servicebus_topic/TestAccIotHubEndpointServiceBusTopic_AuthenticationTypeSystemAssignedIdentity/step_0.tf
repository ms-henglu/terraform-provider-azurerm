

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-240105063948999998"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-240105063948999998"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name         = "acctestservicebustopic-240105063948999998"
  namespace_id = azurerm_servicebus_namespace.test.id
}

resource "azurerm_servicebus_topic_authorization_rule" "test" {
  name     = "acctest-240105063948999998"
  topic_id = azurerm_servicebus_topic.test.id

  listen = false
  send   = true
  manage = false
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestuai-240105063948999998"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_role_assignment" "test_azure_service_bus_data_sender_user" {
  role_definition_name = "Azure Service Bus Data Sender"
  scope                = azurerm_servicebus_topic.test.id
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-240105063948999998"
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
    azurerm_role_assignment.test_azure_service_bus_data_sender_user,
  ]
}

resource "azurerm_role_assignment" "test_azure_service_bus_data_sender_system" {
  role_definition_name = "Azure Service Bus Data Sender"
  scope                = azurerm_servicebus_topic.test.id
  principal_id         = azurerm_iothub.test.identity[0].principal_id
}


resource "azurerm_iothub_endpoint_servicebus_topic" "test" {
  resource_group_name = azurerm_resource_group.test.name
  iothub_id           = azurerm_iothub.test.id
  name                = "acctest"

  authentication_type = "identityBased"
  endpoint_uri        = "sb://${azurerm_servicebus_namespace.test.name}.servicebus.windows.net"
  entity_path         = azurerm_servicebus_topic.test.name

  depends_on = [
    azurerm_role_assignment.test_azure_service_bus_data_sender_system,
  ]
}
