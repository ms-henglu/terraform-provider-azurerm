
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105061256911207"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan240105061256911207"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
