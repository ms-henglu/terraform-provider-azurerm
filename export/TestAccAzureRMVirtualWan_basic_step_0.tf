
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029015948881597"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211029015948881597"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
