
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-230113181110692132"
  location = "West Europe"
}
resource "azurerm_servicebus_namespace" "example" {
  name                = "acctestservicebusnamespace-230113181110692132"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}
resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-230113181110692132"
  namespace_id        = azurerm_servicebus_namespace.example.id
  enable_partitioning = true
}
resource "azurerm_eventgrid_event_subscription" "test" {
  name                          = "acctest-eg-230113181110692132"
  scope                         = azurerm_resource_group.test.id
  event_delivery_schema         = "CloudEventSchemaV1_0"
  service_bus_topic_endpoint_id = azurerm_servicebus_topic.test.id
}
