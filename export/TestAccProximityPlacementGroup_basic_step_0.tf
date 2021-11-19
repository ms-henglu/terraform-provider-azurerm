
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211119050629415573"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-211119050629415573"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
