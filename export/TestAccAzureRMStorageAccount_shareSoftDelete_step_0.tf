

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-211015015210691502"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctruedg"
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
  name                 = "testshareruedg"
  storage_account_name = azurerm_storage_account.test.name
}

resource "azurerm_storage_share_file" "test" {
  name             = "dir"
  storage_share_id = azurerm_storage_share.test.id

  source = "/tmp/237230049"

  metadata = {
    hello = "world"
  }
}
