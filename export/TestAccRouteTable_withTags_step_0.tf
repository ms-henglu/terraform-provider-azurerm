
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072215433287"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt211013072215433287"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  route {
    name           = "route1"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "vnetlocal"
  }

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
