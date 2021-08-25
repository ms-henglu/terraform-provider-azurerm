
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-210825043124146048"
  location = "West US 2"
}

resource "azurerm_nat_gateway" "test" {
  name                = "acctestnatGateway-210825043124146048"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
