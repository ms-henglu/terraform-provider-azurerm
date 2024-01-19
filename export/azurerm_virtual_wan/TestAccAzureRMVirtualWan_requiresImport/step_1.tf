

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527751177"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan240119025527751177"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_virtual_wan" "import" {
  name                = azurerm_virtual_wan.test.name
  resource_group_name = azurerm_virtual_wan.test.resource_group_name
  location            = azurerm_virtual_wan.test.location
}
