
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-221021034111597265"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "example" {
  name                = "acctestservicebusnamespace-221021034111597265"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}
resource "azurerm_servicebus_queue" "test" {
  name                = "acctestservicebusqueue-221021034111597265"
  namespace_id        = azurerm_servicebus_namespace.example.id
  enable_partitioning = true
}
resource "azurerm_eventgrid_event_subscription" "test" {
  name                          = "acctest-eg-221021034111597265"
  scope                         = azurerm_resource_group.test.id
  event_delivery_schema         = "CloudEventSchemaV1_0"
  service_bus_queue_endpoint_id = azurerm_servicebus_queue.test.id
}
