
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-220107064444257654"
  location = "West US 2"
}

resource "azurerm_nat_gateway" "test" {
  name                = "acctestnatGateway-220107064444257654"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
