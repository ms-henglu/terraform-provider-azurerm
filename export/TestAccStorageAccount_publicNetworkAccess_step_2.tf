
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220916012108364675"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acct1bdlc"
  resource_group_name = azurerm_resource_group.test.name

  location                      = azurerm_resource_group.test.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = false
}
