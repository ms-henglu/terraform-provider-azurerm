
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240311031853871570"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                            = "acctestsa7njt9"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_kind                    = "BlobStorage"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  is_hns_enabled                  = true
  allow_nested_items_to_be_public = true
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-datalake-240311031853871570"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240311031853871570"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_data_factory.test.identity.0.principal_id
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "test" {
  name                 = "acctestDataLakeStorage240311031853871570"
  data_factory_id      = azurerm_data_factory.test.id
  use_managed_identity = true
  url                  = azurerm_storage_account.test.primary_dfs_endpoint
}

resource "azurerm_data_factory_dataset_delimited_text" "test" {
  name                = "acctestds240311031853871570"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.test.name

  azure_blob_fs_location {
    file_system = azurerm_storage_data_lake_gen2_filesystem.test.name
    path        = "foo/bar/"
    filename    = "a.csv"
  }

  column_delimiter    = ","
  row_delimiter       = "NEW"
  encoding            = "UTF-8"
  quote_character     = "x"
  escape_character    = "f"
  first_row_as_header = true
  null_value          = "NULL"
}
