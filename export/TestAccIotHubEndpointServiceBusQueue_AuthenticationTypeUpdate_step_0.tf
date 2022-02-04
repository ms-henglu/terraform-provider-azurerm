

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-220204060147913463"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "test" {
  name                = "acctest-220204060147913463"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "test" {
  name                = "acctest-220204060147913463"
  resource_group_name = azurerm_resource_group.test.name
  namespace_name      = azurerm_servicebus_namespace.test.name

  enable_partitioning = true
}

resource "azurerm_servicebus_queue_authorization_rule" "test" {
  name                = "acctest-220204060147913463"
  namespace_name      = azurerm_servicebus_namespace.test.name
  queue_name          = azurerm_servicebus_queue.test.name
  resource_group_name = azurerm_resource_group.test.name

  listen = false
  send   = true
  manage = false
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestuai-220204060147913463"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_role_assignment" "test_azure_service_bus_data_sender_user" {
  role_definition_name = "Azure Service Bus Data Sender"
  scope                = azurerm_servicebus_queue.test.id
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-220204060147913463"
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
  scope                = azurerm_servicebus_queue.test.id
  principal_id         = azurerm_iothub.test.identity[0].principal_id
}


resource "azurerm_iothub_endpoint_servicebus_queue" "test" {
  resource_group_name = azurerm_resource_group.test.name
  iothub_name         = azurerm_iothub.test.name
  name                = "acctest"

  connection_string = azurerm_servicebus_queue_authorization_rule.test.primary_connection_string
}
