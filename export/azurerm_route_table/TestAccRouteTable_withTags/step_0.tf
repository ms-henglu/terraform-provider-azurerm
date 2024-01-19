
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527728960"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt240119025527728960"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  route {
    name           = "route1"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
