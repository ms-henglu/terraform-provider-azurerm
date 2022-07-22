
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722052327010914"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan220722052327010914"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
