
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034431069175"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan231016034431069175"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
