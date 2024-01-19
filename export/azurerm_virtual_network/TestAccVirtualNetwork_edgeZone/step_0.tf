
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527753517"
  location = "westus"
}

data "azurerm_extended_locations" "test" {
  location = azurerm_resource_group.test.location
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet240119025527753517"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  edge_zone           = data.azurerm_extended_locations.test.extended_locations[0]
}
