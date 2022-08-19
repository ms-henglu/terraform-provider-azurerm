
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220819165535299791"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220819165535299791"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
