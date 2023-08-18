


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818024852734730"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacclsc8v"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}


resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-230818024852734730"
  storage_account_id = azurerm_storage_account.test.id
}


resource "azurerm_storage_data_lake_gen2_filesystem" "import" {
  name               = azurerm_storage_data_lake_gen2_filesystem.test.name
  storage_account_id = azurerm_storage_data_lake_gen2_filesystem.test.storage_account_id
}
