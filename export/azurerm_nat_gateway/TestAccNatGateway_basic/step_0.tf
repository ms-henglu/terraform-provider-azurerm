
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-230414021841257870"
  location = "West US 2"
}

resource "azurerm_nat_gateway" "test" {
  name                = "acctestnatGateway-230414021841257870"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
