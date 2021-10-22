
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211022001757121805"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-211022001757121805"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
