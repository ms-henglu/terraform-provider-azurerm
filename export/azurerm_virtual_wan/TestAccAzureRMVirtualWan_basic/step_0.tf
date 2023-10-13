
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013043954376669"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan231013043954376669"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
