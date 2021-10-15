
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-211015014623682421"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "example" {
  name                = "acctestservicebusnamespace-211015014623682421"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}
resource "azurerm_servicebus_queue" "test" {
  name                = "acctestservicebusqueue-211015014623682421"
  resource_group_name = azurerm_resource_group.test.name
  namespace_name      = azurerm_servicebus_namespace.example.name
  enable_partitioning = true
}
resource "azurerm_eventgrid_event_subscription" "test" {
  name                          = "acctest-eg-211015014623682421"
  scope                         = azurerm_resource_group.test.id
  event_delivery_schema         = "CloudEventSchemaV1_0"
  service_bus_queue_endpoint_id = azurerm_servicebus_queue.test.id
}
