
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211001053637607626"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestdfolqgv"
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
  name                = "acctestdf211001053637607626"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_data_factory_linked_service_azure_blob_storage" "test" {
  name                = "acctestlsblob211001053637607626"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  connection_string   = azurerm_storage_account.test.primary_connection_string
}

resource "azurerm_data_factory_dataset_parquet" "test" {
  name                = "acctestds211001053637607626"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.test.name

  azure_blob_storage_location {
    container            = azurerm_storage_container.test.name
    path                 = "@concat('foo/bar/',formatDateTime(convertTimeZone(utcnow(),'UTC','W. Europe Standard Time'),'yyyy-MM-dd'))"
    dynamic_path_enabled = true
  }
}
