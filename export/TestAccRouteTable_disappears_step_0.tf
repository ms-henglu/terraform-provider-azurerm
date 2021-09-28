
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928055740876956"
  location = "West Europe"
}

resource "azurerm_route_table" "test" {
  name                = "acctestrt210928055740876956"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
