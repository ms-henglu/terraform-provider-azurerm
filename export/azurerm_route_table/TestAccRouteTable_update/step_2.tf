
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032742225093"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt240311032742225093"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  route {
    name           = "acctestRoute"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  disable_bgp_route_propagation = true
}
