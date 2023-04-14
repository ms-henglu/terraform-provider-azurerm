

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230414021841239119"
  location = "West Europe"
}


resource "azurerm_express_route_port" "test" {
  name                = "acctestERP-230414021841239119"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  peering_location    = "Airtel-Chennai2-CLS"
  bandwidth_in_gbps   = 10
  encapsulation       = "Dot1Q"
  billing_type        = "MeteredData"
  tags = {
    ENV = "Test"
  }
}
