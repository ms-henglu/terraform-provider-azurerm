
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428045412211975"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-230428045412211975"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
