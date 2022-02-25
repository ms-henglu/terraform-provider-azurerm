

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220225035100711998"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccb4k7b"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}


resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-220225035100711998"
  storage_account_id = azurerm_storage_account.test.id

  properties = {
    key = "aGVsbG8="
  }
}
