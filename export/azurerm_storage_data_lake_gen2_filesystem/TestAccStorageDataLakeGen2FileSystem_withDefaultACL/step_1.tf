


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421023011039549"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccglu3q"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}


resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-230421023011039549"
  storage_account_id = azurerm_storage_account.test.id
}


resource "azurerm_storage_data_lake_gen2_filesystem" "import" {
  name               = azurerm_storage_data_lake_gen2_filesystem.test.name
  storage_account_id = azurerm_storage_data_lake_gen2_filesystem.test.storage_account_id
}
