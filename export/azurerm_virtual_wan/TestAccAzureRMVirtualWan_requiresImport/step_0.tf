
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313021634765598"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan230313021634765598"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
