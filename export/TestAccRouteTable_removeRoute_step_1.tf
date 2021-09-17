
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210917032023388301"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt210917032023388301"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
