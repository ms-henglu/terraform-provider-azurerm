
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-211112021019932138"
  location = "West US 2"
}

resource "azurerm_nat_gateway" "test" {
  name                = "acctestnatGateway-211112021019932138"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
