
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231020040940431998"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestdfydih6"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "test" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf231020040940431998"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "test" {
  name                = "acctestlsdls231020040940431998"
  data_factory_id     = azurerm_data_factory.test.id
  url                 = azurerm_storage_account.test.primary_dfs_endpoint
  storage_account_key = azurerm_storage_account.test.primary_access_key
}

resource "azurerm_data_factory_dataset_parquet" "test" {
  name                = "acctestds231020040940431998"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.test.name

  azure_blob_fs_location {
    file_system                 = azurerm_storage_container.test.name
    dynamic_file_system_enabled = true
    path                        = "@concat('foo/bar/',formatDateTime(convertTimeZone(utcnow(),'UTC','W. Europe Standard Time'),'yyyy-MM-dd'))"
    dynamic_path_enabled        = true
  }
}
