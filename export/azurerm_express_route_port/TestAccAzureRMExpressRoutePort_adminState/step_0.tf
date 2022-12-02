

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202040144946577"
  location = "West Europe"
}


resource "azurerm_express_route_port" "test" {
  name                = "acctestERP-221202040144946577"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  peering_location    = "Area51-ERDirect"
  bandwidth_in_gbps   = 10
  encapsulation       = "Dot1Q"
  link1 {
    admin_enabled = true
  }
}
