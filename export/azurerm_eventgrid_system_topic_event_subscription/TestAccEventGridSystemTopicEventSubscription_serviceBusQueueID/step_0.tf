
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-240119025027126838"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "example" {
  name                = "acctestservicebusnamespace-240119025027126838"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

resource "azurerm_servicebus_queue" "test" {
  name                = "acctestservicebusqueue-240119025027126838"
  namespace_id        = azurerm_servicebus_namespace.example.id
  enable_partitioning = true
}

resource "azurerm_eventgrid_system_topic" "test" {
  name                   = "acctesteg-240119025027126838"
  location               = "Global"
  resource_group_name    = azurerm_resource_group.test.name
  source_arm_resource_id = azurerm_resource_group.test.id
  topic_type             = "Microsoft.Resources.ResourceGroups"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "test" {
  name                = "acctesteg-240119025027126838"
  system_topic        = azurerm_eventgrid_system_topic.test.name
  resource_group_name = azurerm_resource_group.test.name

  event_delivery_schema         = "CloudEventSchemaV1_0"
  service_bus_queue_endpoint_id = azurerm_servicebus_queue.test.id
}
