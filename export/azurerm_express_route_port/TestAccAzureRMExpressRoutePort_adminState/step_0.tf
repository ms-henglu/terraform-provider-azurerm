

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526085609972034"
  location = "West Europe"
}


resource "azurerm_express_route_port" "test" {
  name                = "acctestERP-230526085609972034"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  peering_location    = "Area51-ERDirect"
  bandwidth_in_gbps   = 10
  encapsulation       = "Dot1Q"
  link1 {
    admin_enabled = true
  }
}
