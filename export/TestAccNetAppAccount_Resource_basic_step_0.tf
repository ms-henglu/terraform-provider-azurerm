
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-211008044734346635"
  location = "West Europe"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-211008044734346635"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
