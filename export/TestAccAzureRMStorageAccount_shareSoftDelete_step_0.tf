

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220527034746121679"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2accte0hwg"
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
  name                 = "testsharee0hwg"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 1
}

resource "azurerm_storage_share_file" "test" {
  name             = "dir"
  storage_share_id = azurerm_storage_share.test.id

  source = "/tmp/058841787"

  metadata = {
    hello = "world"
  }
}
