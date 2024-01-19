

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025027130044"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-240119025027130044"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_eventgrid_topic" "import" {
  name                = azurerm_eventgrid_topic.test.name
  location            = azurerm_eventgrid_topic.test.location
  resource_group_name = azurerm_eventgrid_topic.test.resource_group_name
}
