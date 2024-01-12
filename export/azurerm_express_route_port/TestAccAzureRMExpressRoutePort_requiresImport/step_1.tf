


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112034901513852"
  location = "West Europe"
}


resource "azurerm_express_route_port" "test" {
  name                = "acctestERP-240112034901513852"
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


resource "azurerm_express_route_port" "import" {
  name                = azurerm_express_route_port.test.name
  resource_group_name = azurerm_express_route_port.test.resource_group_name
  location            = azurerm_express_route_port.test.location
  peering_location    = azurerm_express_route_port.test.peering_location
  bandwidth_in_gbps   = azurerm_express_route_port.test.bandwidth_in_gbps
  encapsulation       = azurerm_express_route_port.test.encapsulation
}
