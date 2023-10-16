
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034431035431"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt231016034431035431"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  route {
    name           = "route1"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  route {
    name           = "route2"
    address_prefix = "10.2.0.0/16"
    next_hop_type  = "VnetLocal"
  }
}
