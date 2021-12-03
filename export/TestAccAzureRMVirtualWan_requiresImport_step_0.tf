
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203014217285326"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211203014217285326"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
