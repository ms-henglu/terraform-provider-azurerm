
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211105035757865868"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestdf3la3c"
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
  name                = "acctestdf211105035757865868"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_data_factory_linked_service_azure_blob_storage" "test" {
  name                = "acctestlsblob211105035757865868"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  connection_string   = azurerm_storage_account.test.primary_connection_string
}

resource "azurerm_data_factory_dataset_binary" "test" {
  name                = "acctestds211105035757865868"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.test.name

  azure_blob_storage_location {
    container = azurerm_storage_container.test.name
  }
}
