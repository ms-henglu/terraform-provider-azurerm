
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-231016033913526561"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-231016033913526561"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-231016033913526561"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventgrid_system_topic" "test" {
  name                   = "acctesteg-231016033913526561"
  location               = "Global"
  resource_group_name    = azurerm_resource_group.test.name
  source_arm_resource_id = azurerm_resource_group.test.id
  topic_type             = "Microsoft.Resources.ResourceGroups"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "test" {
  name                = "acctesteg-231016033913526561"
  system_topic        = azurerm_eventgrid_system_topic.test.name
  resource_group_name = azurerm_resource_group.test.name

  event_delivery_schema = "CloudEventSchemaV1_0"

  eventhub_endpoint_id = azurerm_eventhub.test.id
}
