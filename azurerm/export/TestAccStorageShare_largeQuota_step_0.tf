
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storageshare-220627130245825081"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsharebilrk"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_share" "test" {
  name                 = "testsharebilrk"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 6000
}
