
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001224344413038"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt211001224344413038"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
