
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-220527034504830574"
  location = "West Europe"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-220527034504830574"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
