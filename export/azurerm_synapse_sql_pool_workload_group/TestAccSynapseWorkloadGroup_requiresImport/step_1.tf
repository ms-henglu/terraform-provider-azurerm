


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-231020042017537048"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc8ktb8"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-231020042017537048"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw231020042017537048"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_synapse_sql_pool" "test" {
  name                 = "acctestSP8ktb8"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  sku_name             = "DW100c"
  create_mode          = "Default"
  storage_account_type = "GRS"
}


resource "azurerm_synapse_sql_pool_workload_group" "test" {
  name                             = "acctestWG8ktb8"
  sql_pool_id                      = azurerm_synapse_sql_pool.test.id
  max_resource_percent             = 100
  min_resource_percent             = 0
  min_resource_percent_per_request = 3
}


resource "azurerm_synapse_sql_pool_workload_group" "import" {
  name                             = azurerm_synapse_sql_pool_workload_group.test.name
  sql_pool_id                      = azurerm_synapse_sql_pool_workload_group.test.sql_pool_id
  max_resource_percent             = 100
  min_resource_percent             = 0
  min_resource_percent_per_request = 3
}
