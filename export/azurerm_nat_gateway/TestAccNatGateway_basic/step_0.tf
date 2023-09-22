
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-230922054621693493"
  location = "West US 2"
}

resource "azurerm_nat_gateway" "test" {
  name                = "acctestnatGateway-230922054621693493"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
