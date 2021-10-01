
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001020609124326"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-211001020609124326"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-211001020609124326"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  proximity_placement_group_id = azurerm_proximity_placement_group.test.id
}
