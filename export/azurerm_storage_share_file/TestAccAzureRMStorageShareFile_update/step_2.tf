

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-230818024852747949"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsayayva"
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


  content_type        = "test_content_type"
  content_encoding    = "test_encoding"
  content_disposition = "test_content_disposition"
  content_md5         = "1234567890abcdef1234567890abcdef"

  metadata = {
    hello = "world"
  }
}
