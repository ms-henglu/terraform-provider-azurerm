
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826002453833807"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-220826002453833807"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-220826002453833807"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  proximity_placement_group_id = azurerm_proximity_placement_group.test.id
}
