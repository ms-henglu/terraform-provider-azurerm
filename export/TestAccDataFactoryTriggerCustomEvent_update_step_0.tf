

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211001020702338381"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211001020702338381"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_pipeline" "test" {
  name                = "acctest211001020702338381"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name

  parameters = {
    foo = "bar"
  }
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-211001020702338381"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_data_factory_trigger_custom_event" "test" {
  name                = "acctestdf211001020702338381"
  data_factory_id     = azurerm_data_factory.test.id
  eventgrid_topic_id  = azurerm_eventgrid_topic.test.id
  events              = ["event1"]
  subject_begins_with = "abc"

  pipeline {
    name = azurerm_data_factory_pipeline.test.name
  }
}
