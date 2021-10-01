

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001020755201273"
  location = "westus2"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-211001020755201273"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_eventgrid_topic" "import" {
  name                = azurerm_eventgrid_topic.test.name
  location            = azurerm_eventgrid_topic.test.location
  resource_group_name = azurerm_eventgrid_topic.test.resource_group_name
}
