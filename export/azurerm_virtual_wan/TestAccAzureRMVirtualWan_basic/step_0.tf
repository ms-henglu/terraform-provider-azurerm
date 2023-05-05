
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230505050951403196"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan230505050951403196"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
