
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041557369060"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan231020041557369060"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
