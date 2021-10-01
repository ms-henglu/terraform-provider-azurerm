
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001224344430957"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211001224344430957"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
