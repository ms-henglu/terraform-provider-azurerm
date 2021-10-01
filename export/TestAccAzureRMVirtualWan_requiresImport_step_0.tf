
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001224344439190"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211001224344439190"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
