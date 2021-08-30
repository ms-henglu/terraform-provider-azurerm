
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210830083901625214"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf210830083901625214"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_storage_account" "test" {
  name                     = "testaccsag3hd0"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  allow_blob_public_access = true
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "test" {
  name                = "acctestDataLake210830083901625214"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  url                 = azurerm_storage_account.test.primary_dfs_endpoint
  storage_account_key = azurerm_storage_account.test.primary_access_key
}
