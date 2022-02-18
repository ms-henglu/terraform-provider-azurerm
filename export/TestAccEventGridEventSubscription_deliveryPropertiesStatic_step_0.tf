
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-220218070743143593"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "example" {
  name                = "acctestservicebusnamespace-220218070743143593"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}
resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-220218070743143593"
  resource_group_name = azurerm_resource_group.test.name
  namespace_name      = azurerm_servicebus_namespace.example.name
  enable_partitioning = true
}

resource "azurerm_eventgrid_event_subscription" "test" {
  name  = "acctest-eg-220218070743143593"
  scope = azurerm_resource_group.test.id

  service_bus_topic_endpoint_id = azurerm_servicebus_topic.test.id

  advanced_filtering_on_arrays_enabled = true

  subject_filter {
    subject_begins_with = "test/test"
  }

  delivery_property {
    header_name = "test-1"
    type        = "Static"
    value       = "1"
    secret      = false
  }

  delivery_property {
    header_name = "test-2"
    type        = "Static"
    value       = "string"
    secret      = false
  }

}
