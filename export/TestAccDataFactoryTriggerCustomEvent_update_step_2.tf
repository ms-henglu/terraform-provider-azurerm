

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211112020507586652"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211112020507586652"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name                = "acctest211112020507586652"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name

  parameters = {
    foo = "bar"
  }
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-211112020507586652"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_data_factory_trigger_custom_event" "test" {
  name                = "acctestdf211112020507586652"
  data_factory_id     = azurerm_data_factory.test.id
  eventgrid_topic_id  = azurerm_eventgrid_topic.test.id
  events              = ["event1", "event2"]
  subject_begins_with = "abc"
  subject_ends_with   = "xyz"

  activated   = false
  annotations = ["test1", "test2", "test3"]
  description = "test description"

  pipeline {
    name = azurerm_data_factory_pipeline.test.name
    parameters = {
      Env = "Test"
    }
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }
}
