
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221019054722405625"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt221019054722405625"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
