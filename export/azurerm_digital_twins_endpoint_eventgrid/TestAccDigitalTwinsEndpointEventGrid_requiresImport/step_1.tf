




provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-240105060711215590"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-240105060711215590"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-240105060711215590"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_digital_twins_endpoint_eventgrid" "test" {
  name                                 = "acctest-EG-240105060711215590"
  digital_twins_id                     = azurerm_digital_twins_instance.test.id
  eventgrid_topic_endpoint             = azurerm_eventgrid_topic.test.endpoint
  eventgrid_topic_primary_access_key   = azurerm_eventgrid_topic.test.primary_access_key
  eventgrid_topic_secondary_access_key = azurerm_eventgrid_topic.test.secondary_access_key
}


resource "azurerm_digital_twins_endpoint_eventgrid" "import" {
  name                                 = azurerm_digital_twins_endpoint_eventgrid.test.name
  digital_twins_id                     = azurerm_digital_twins_endpoint_eventgrid.test.digital_twins_id
  eventgrid_topic_endpoint             = azurerm_digital_twins_endpoint_eventgrid.test.eventgrid_topic_endpoint
  eventgrid_topic_primary_access_key   = azurerm_digital_twins_endpoint_eventgrid.test.eventgrid_topic_primary_access_key
  eventgrid_topic_secondary_access_key = azurerm_digital_twins_endpoint_eventgrid.test.eventgrid_topic_secondary_access_key
}
