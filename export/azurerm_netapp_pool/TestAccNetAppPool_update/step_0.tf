
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-221021031537353325"
  location = "West Europe"

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true",
    "SkipNRMSNSG"      = "true"
  }
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-221021031537353325"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_netapp_pool" "test" {
  name                = "acctest-NetAppPool-221021031537353325"
  account_name        = azurerm_netapp_account.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_level       = "Standard"
  size_in_tb          = 4

  tags = {
    "CreatedOnDate" = "2022-07-08T23:50:21Z",
  }
}
