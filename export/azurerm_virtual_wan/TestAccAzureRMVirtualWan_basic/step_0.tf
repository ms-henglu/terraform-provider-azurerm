
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202040145043564"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan221202040145043564"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
