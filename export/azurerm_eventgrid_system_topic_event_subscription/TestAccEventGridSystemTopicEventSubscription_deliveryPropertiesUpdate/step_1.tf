
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-230915023410429480"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "example" {
  name                = "acctestservicebusnamespace-230915023410429480"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-230915023410429480"
  namespace_id        = azurerm_servicebus_namespace.example.id
  enable_partitioning = true
}

resource "azurerm_eventgrid_system_topic" "test" {
  name                   = "acctesteg-230915023410429480"
  location               = "Global"
  resource_group_name    = azurerm_resource_group.test.name
  source_arm_resource_id = azurerm_resource_group.test.id
  topic_type             = "Microsoft.Resources.ResourceGroups"
}

resource "azurerm_eventgrid_system_topic_event_subscription" "test" {
  name                = "acctesteg-230915023410429480"
  system_topic        = azurerm_eventgrid_system_topic.test.name
  resource_group_name = azurerm_resource_group.test.name

  service_bus_topic_endpoint_id = azurerm_servicebus_topic.test.id

  advanced_filtering_on_arrays_enabled = true

  subject_filter {
    subject_begins_with = "test/test"
  }

  delivery_property {
    header_name = "test-static-1"
    type        = "Static"
    value       = "2"
    secret      = false
  }

  delivery_property {
    header_name  = "test-dynamic-1"
    type         = "Dynamic"
    source_field = "data.topic"
  }

  delivery_property {
    header_name = "test-secret-1"
    type        = "Static"
    value       = "this-value-is-still-secret!"
    secret      = true
  }
}
