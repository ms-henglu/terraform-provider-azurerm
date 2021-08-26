
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210826023203586435"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-210826023203586435"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
