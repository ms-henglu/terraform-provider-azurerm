
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030421803123"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230804030421803123"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  route {
    name           = "route1"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
  }
}
