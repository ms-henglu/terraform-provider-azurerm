
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211022002300426121"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan211022002300426121"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
