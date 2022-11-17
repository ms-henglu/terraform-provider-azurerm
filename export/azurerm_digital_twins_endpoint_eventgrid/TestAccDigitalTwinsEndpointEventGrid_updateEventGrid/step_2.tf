



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-dtwin-221117230825660222"
  location = "West Europe"
}


resource "azurerm_digital_twins_instance" "test" {
  name                = "acctest-DT-221117230825660222"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-221117230825660222"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_eventgrid_topic" "test_alt" {
  name                = "acctesteg-alt-221117230825660222"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_digital_twins_endpoint_eventgrid" "test" {
  name                                 = "acctest-EG-221117230825660222"
  digital_twins_id                     = azurerm_digital_twins_instance.test.id
  eventgrid_topic_endpoint             = azurerm_eventgrid_topic.test_alt.endpoint
  eventgrid_topic_primary_access_key   = azurerm_eventgrid_topic.test_alt.primary_access_key
  eventgrid_topic_secondary_access_key = azurerm_eventgrid_topic.test_alt.secondary_access_key
}
