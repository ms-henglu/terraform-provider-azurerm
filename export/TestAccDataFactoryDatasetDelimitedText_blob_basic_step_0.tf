
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220225034258398029"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestdfe0pib"
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
  name                = "acctestdf220225034258398029"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_data_factory_linked_service_azure_blob_storage" "test" {
  name                = "acctestlsblob220225034258398029"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_id     = azurerm_data_factory.test.id
  connection_string   = azurerm_storage_account.test.primary_connection_string
}

resource "azurerm_data_factory_dataset_delimited_text" "test" {
  name                = "acctestds220225034258398029"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_id     = azurerm_data_factory.test.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.test.name

  azure_blob_storage_location {
    container = azurerm_storage_container.test.name
    path      = "foo/bar/"
    filename  = "foo.txt"
  }
}
