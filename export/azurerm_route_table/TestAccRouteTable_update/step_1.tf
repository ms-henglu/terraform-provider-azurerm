
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527721178"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt240119025527721178"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  route {
    name                   = "route1"
    address_prefix         = "10.1.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "192.168.0.1"
  }
}
