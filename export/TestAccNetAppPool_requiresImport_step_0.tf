
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-220527034504834147"
  location = "West Europe"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-220527034504834147"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_netapp_pool" "test" {
  name                = "acctest-NetAppPool-220527034504834147"
  account_name        = azurerm_netapp_account.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_level       = "Standard"
  size_in_tb          = 4
}
