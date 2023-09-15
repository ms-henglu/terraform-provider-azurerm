

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023921291879"
  location = "West Europe"
}


resource "azurerm_express_route_port" "test" {
  name                = "acctestERP-230915023921291879"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  peering_location    = "Area51-ERDirect"
  bandwidth_in_gbps   = 10
  encapsulation       = "Dot1Q"
  link1 {
    admin_enabled = true
  }
}
