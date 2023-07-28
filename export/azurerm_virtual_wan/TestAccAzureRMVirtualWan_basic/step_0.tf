
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728032804046051"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan230728032804046051"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
