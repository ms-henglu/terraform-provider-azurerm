
provider "azurerm" {
  storage_use_azuread = true
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315124154211006"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa41dgw"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name                 = "fileshare"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 50
}

resource "azurerm_storage_share_directory" "test" {
  name             = "dir"
  storage_share_id = azurerm_storage_share.test.id
}
