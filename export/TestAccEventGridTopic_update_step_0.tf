
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610092659378621"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-220610092659378621"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
