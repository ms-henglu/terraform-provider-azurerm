
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211210034558582800"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211210034558582800"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_storage_account" "test" {
  name                     = "testaccsa339p7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  allow_blob_public_access = true
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "test" {
  name                = "acctestDataLake211210034558582800"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_id     = azurerm_data_factory.test.id
  url                 = azurerm_storage_account.test.primary_dfs_endpoint
  storage_account_key = azurerm_storage_account.test.primary_access_key
}
