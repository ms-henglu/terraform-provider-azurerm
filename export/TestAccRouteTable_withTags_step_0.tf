
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220225034758948699"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt220225034758948699"
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
