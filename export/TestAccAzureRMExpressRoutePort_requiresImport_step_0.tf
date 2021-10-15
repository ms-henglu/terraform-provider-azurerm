

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014936421595"
  location = "West Europe"
}


resource "azurerm_express_route_port" "test" {
  name                = "acctestERP-211015014936421595"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  peering_location    = "Airtel-Chennai2-CLS"
  bandwidth_in_gbps   = 10
  encapsulation       = "Dot1Q"
  tags = {
    ENV = "Test"
  }
}
