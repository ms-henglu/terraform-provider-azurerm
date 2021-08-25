
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210825025712799757"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf210825025712799757"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_storage_account" "test" {
  name                     = "testaccsahwb8g"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  allow_blob_public_access = true
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "test" {
  name                = "acctestDataLake210825025712799757"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  url                 = azurerm_storage_account.test.primary_dfs_endpoint
  storage_account_key = azurerm_storage_account.test.primary_access_key
}
