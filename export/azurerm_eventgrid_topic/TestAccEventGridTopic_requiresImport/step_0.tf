
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230519074742510000"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-230519074742510000"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
