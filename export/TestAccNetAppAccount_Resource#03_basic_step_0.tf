
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-210825030036357630"
  location = "West Europe"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-210825030036357630"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
