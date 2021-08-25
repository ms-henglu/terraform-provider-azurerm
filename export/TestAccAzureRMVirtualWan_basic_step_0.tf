
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825030045185987"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan210825030045185987"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
