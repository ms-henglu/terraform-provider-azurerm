
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-220715004429913689"
  location = "West Europe"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-220715004429913689"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

resource "azurerm_eventhub" "test" {
  name                = "acctesteventhub-220715004429913689"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventgrid_event_subscription" "test" {
  name                  = "acctest-eg-220715004429913689"
  scope                 = azurerm_resource_group.test.id
  event_delivery_schema = "CloudEventSchemaV1_0"

  eventhub_endpoint_id = azurerm_eventhub.test.id

  delivery_property {
    header_name = "test-static-1"
    type        = "Static"
    value       = "1"
  }
}
