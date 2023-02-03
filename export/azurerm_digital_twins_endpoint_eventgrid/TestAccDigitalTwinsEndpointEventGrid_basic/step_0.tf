



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-230203063300808982"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-230203063300808982"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-230203063300808982"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_digital_twins_endpoint_eventgrid" "test" {
  name                                 = "acctest-EG-230203063300808982"
  digital_twins_id                     = azurerm_digital_twins_instance.test.id
  eventgrid_topic_endpoint             = azurerm_eventgrid_topic.test.endpoint
  eventgrid_topic_primary_access_key   = azurerm_eventgrid_topic.test.primary_access_key
  eventgrid_topic_secondary_access_key = azurerm_eventgrid_topic.test.secondary_access_key
}
