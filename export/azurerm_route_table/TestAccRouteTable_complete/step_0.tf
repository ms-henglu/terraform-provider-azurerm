
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230127045836052748"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230127045836052748"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  route {
    name           = "acctestRoute"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  disable_bgp_route_propagation = true
}
