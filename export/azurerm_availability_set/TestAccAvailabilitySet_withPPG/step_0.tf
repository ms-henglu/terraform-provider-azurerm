
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028171853795189"
  location = "West Europe"
}

resource "azurerm_proximity_placement_group" "test" {
  name                = "acctestPPG-221028171853795189"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_availability_set" "test" {
  name                = "acctestavset-221028171853795189"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  proximity_placement_group_id = azurerm_proximity_placement_group.test.id
}
