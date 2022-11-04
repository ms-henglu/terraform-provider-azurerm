
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221104005221355662"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-221104005221355662"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
