
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220225035100837717"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacclui2t"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "testsharelui2t"
  storage_account_name = azurerm_storage_account.test.name
  enabled_protocol     = "NFS"
}
