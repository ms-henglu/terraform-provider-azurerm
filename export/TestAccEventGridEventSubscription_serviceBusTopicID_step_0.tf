
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-211210024605785796"
  location = "West Europe"
}
resource "azurerm_servicebus_namespace" "example" {
  name                = "acctestservicebusnamespace-211210024605785796"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}
resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-211210024605785796"
  resource_group_name = azurerm_resource_group.test.name
  namespace_name      = azurerm_servicebus_namespace.example.name
  enable_partitioning = true
}
resource "azurerm_eventgrid_event_subscription" "test" {
  name                          = "acctest-eg-211210024605785796"
  scope                         = azurerm_resource_group.test.id
  event_delivery_schema         = "CloudEventSchemaV1_0"
  service_bus_topic_endpoint_id = azurerm_servicebus_topic.test.id
}
