
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210826023659357998"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan210826023659357998"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
