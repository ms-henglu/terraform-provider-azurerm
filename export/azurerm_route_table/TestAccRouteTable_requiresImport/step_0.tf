
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031750869953"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt230106031750869953"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
