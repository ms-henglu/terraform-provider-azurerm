
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001021055728018"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211001021055728018"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
