
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014936466613"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211015014936466613"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
