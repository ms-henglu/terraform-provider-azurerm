
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204056157576"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-221221204056157576"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
