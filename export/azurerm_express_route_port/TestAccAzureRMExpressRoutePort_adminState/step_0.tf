

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021031543700058"
  location = "West Europe"
}


resource "azurerm_express_route_port" "test" {
  name                = "acctestERP-221021031543700058"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  peering_location    = "Area51-ERDirect"
  bandwidth_in_gbps   = 1
  encapsulation       = "Dot1Q"
  link1 {
    admin_enabled = true
  }
}
