
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230707003750977043"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230707003750977043"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_storage_account" "test" {
  name                            = "testaccsa2o6gb"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  is_hns_enabled                  = true
  allow_nested_items_to_be_public = true
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "test" {
  name                = "acctestDataLake230707003750977043"
  data_factory_id     = azurerm_data_factory.test.id
  url                 = azurerm_storage_account.test.primary_dfs_endpoint
  storage_account_key = azurerm_storage_account.test.primary_access_key
}
