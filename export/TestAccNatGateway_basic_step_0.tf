
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-220513023611436077"
  location = "West US 2"
}

resource "azurerm_nat_gateway" "test" {
  name                = "acctestnatGateway-220513023611436077"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
