
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825045040134350"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan210825045040134350"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
