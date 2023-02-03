
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230203063840448947"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan230203063840448947"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
