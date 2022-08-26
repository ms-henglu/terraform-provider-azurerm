

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220826003347766481"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2accti8um7"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  share_properties {
    retention_policy {
      days = 3
    }
  }
}


resource "azurerm_storage_share" "test" {
  name                 = "testsharei8um7"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 1
}

resource "azurerm_storage_share_file" "test" {
  name             = "dir"
  storage_share_id = azurerm_storage_share.test.id

  source = "/tmp/755673704"

  metadata = {
    hello = "world"
  }
}
