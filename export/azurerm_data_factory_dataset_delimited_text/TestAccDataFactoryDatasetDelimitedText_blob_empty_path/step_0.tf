
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240311031853876412"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestdfry7hn"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240311031853876412"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "test" {
  name              = "acctestlsblob240311031853876412"
  data_factory_id   = azurerm_data_factory.test.id
  connection_string = azurerm_storage_account.test.primary_connection_string
}

resource "azurerm_data_factory_dataset_delimited_text" "test" {
  name                = "acctestds240311031853876412"
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.test.name

  azure_blob_storage_location {
    container                = azurerm_storage_container.test.name
    path                     = ""
    filename                 = "@concat('foo', '.txt')"
    dynamic_filename_enabled = true
  }

  column_delimiter    = ","
  row_delimiter       = "NEW"
  encoding            = "UTF-8"
  quote_character     = "x"
  escape_character    = "f"
  first_row_as_header = true
  null_value          = "NULL"

}
