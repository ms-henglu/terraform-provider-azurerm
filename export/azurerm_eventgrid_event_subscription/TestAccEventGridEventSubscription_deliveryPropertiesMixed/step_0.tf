
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-eg-230922061117492328"
  location = "West Europe"
}

resource "azurerm_servicebus_namespace" "example" {
  name                = "acctestservicebusnamespace-230922061117492328"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
}
resource "azurerm_servicebus_topic" "test" {
  name                = "acctestservicebustopic-230922061117492328"
  namespace_id        = azurerm_servicebus_namespace.example.id
  enable_partitioning = true
}

resource "azurerm_eventgrid_event_subscription" "test" {
  name  = "acctest-eg-230922061117492328"
  scope = azurerm_resource_group.test.id

  service_bus_topic_endpoint_id = azurerm_servicebus_topic.test.id

  advanced_filtering_on_arrays_enabled = true

  subject_filter {
    subject_begins_with = "test/test"
  }

  delivery_property {
    header_name = "test-static-1"
    type        = "Static"
    value       = "1"
    secret      = false
  }

  delivery_property {
    header_name  = "test-dynamic-1"
    type         = "Dynamic"
    source_field = "data.system"
  }

  delivery_property {
    header_name = "test-secret-1"
    type        = "Static"
    value       = "this-value-is-secret!"
    secret      = true
  }
}
