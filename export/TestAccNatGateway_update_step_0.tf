
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-211021235322269440"
  location = "West US 2"
}

resource "azurerm_nat_gateway" "test" {
  name                = "acctestnatGateway-211021235322269440"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
