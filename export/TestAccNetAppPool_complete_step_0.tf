
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-220712042609526010"
  location = "West Europe"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-220712042609526010"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_netapp_pool" "test" {
  name                = "acctest-NetAppPool-220712042609526010"
  account_name        = azurerm_netapp_account.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_level       = "Standard"
  size_in_tb          = 15
  qos_type            = "Auto"

  tags = {
    "FoO" = "BaR"
  }
}
