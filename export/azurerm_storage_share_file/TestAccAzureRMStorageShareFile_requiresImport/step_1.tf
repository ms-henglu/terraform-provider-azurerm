


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240112035239906455"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa2z660"
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

  metadata = {
    hello = "world"
  }
}


resource "azurerm_storage_share_file" "import" {
  name             = azurerm_storage_share_file.test.name
  storage_share_id = azurerm_storage_share_file.test.storage_share_id

  metadata = {
    hello = "world"
  }
}
