
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112224456563776"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-240112224456563776"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
