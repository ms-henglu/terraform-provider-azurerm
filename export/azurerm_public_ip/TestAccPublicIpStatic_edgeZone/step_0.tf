
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527717570"
  location = "westus"
}

data "azurerm_extended_locations" "test" {
  location = azurerm_resource_group.test.location
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-240119025527717570"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
  edge_zone           = data.azurerm_extended_locations.test.extended_locations[0]
}
