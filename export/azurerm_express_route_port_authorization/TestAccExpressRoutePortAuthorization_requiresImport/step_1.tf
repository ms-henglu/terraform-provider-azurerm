


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072256326218"
  location = "West Europe"
}

resource "azurerm_express_route_port" "test" {
  name                = "acctestERP-231218072256326218"
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

resource "azurerm_express_route_port_authorization" "test" {
  name                    = "acctestauth231218072256326218"
  express_route_port_name = azurerm_express_route_port.test.name
  resource_group_name     = azurerm_resource_group.test.name
}


resource "azurerm_express_route_port_authorization" "import" {
  name                    = azurerm_express_route_port_authorization.test.name
  express_route_port_name = azurerm_express_route_port_authorization.test.express_route_port_name
  resource_group_name     = azurerm_express_route_port_authorization.test.resource_group_name
}
