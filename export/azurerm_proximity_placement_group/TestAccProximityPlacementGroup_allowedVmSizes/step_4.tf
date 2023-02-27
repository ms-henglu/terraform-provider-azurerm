
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227175227901529"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-230227175227901529"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
