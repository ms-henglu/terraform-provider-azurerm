
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-211008044734343606"
  location = "West Europe"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-211008044734343606"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
