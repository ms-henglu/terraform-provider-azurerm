
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117231247932985"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan221117231247932985"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
