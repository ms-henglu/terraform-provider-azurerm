

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220527034746870864"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa4slsq"
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


resource "azurerm_storage_share_file" "test" {
  name             = "dir"
  storage_share_id = azurerm_storage_share.test.id

  source = "/tmp/1215450199"

  metadata = {
    hello = "world"
  }
}
