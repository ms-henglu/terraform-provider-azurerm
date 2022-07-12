
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042841056901"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacczqiql"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "FileStorage"
  account_tier             = "Premium"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "testsharezqiql"
  storage_account_name = azurerm_storage_account.test.name
  enabled_protocol     = "NFS"
  quota                = 100
}
