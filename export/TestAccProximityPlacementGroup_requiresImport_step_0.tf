
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220124121851406437"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-220124121851406437"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
