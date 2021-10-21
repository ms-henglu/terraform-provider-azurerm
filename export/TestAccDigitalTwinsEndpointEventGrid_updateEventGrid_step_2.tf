



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-211021234950680429"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-211021234950680429"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-211021234950680429"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_eventgrid_topic" "test_alt" {
  name                = "acctesteg-alt-211021234950680429"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_digital_twins_endpoint_eventgrid" "test" {
  name                                 = "acctest-EG-211021234950680429"
  digital_twins_id                     = azurerm_digital_twins_instance.test.id
  eventgrid_topic_endpoint             = azurerm_eventgrid_topic.test_alt.endpoint
  eventgrid_topic_primary_access_key   = azurerm_eventgrid_topic.test_alt.primary_access_key
  eventgrid_topic_secondary_access_key = azurerm_eventgrid_topic.test_alt.secondary_access_key
}
