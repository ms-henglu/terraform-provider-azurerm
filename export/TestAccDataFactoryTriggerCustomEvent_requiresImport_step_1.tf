


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211013071742679892"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211013071742679892"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name                = "acctest211013071742679892"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name

  parameters = {
    foo = "bar"
  }
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-211013071742679892"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_data_factory_trigger_custom_event" "test" {
  name                = "acctestdf211013071742679892"
  data_factory_id     = azurerm_data_factory.test.id
  eventgrid_topic_id  = azurerm_eventgrid_topic.test.id
  events              = ["event1"]
  subject_begins_with = "abc"

  pipeline {
    name = azurerm_data_factory_pipeline.test.name
  }
}


resource "azurerm_data_factory_trigger_custom_event" "import" {
  name                = azurerm_data_factory_trigger_custom_event.test.name
  data_factory_id     = azurerm_data_factory_trigger_custom_event.test.data_factory_id
  eventgrid_topic_id  = azurerm_data_factory_trigger_custom_event.test.eventgrid_topic_id
  events              = azurerm_data_factory_trigger_custom_event.test.events
  subject_begins_with = azurerm_data_factory_trigger_custom_event.test.subject_begins_with

  dynamic "pipeline" {
    for_each = azurerm_data_factory_trigger_custom_event.test.pipeline
    content {
      name = pipeline.value.name
    }
  }
}
