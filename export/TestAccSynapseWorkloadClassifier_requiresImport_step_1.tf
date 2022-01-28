


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-220128083049609901"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacchho4p"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-220128083049609901"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw220128083049609901"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
}

resource "azurerm_synapse_sql_pool" "test" {
  name                 = "acctestSPhho4p"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  sku_name             = "DW100c"
  create_mode          = "Default"
}

resource "azurerm_synapse_sql_pool_workload_group" "test" {
  name                               = "acctestWGhho4p"
  sql_pool_id                        = azurerm_synapse_sql_pool.test.id
  importance                         = "normal"
  max_resource_percent               = 100
  min_resource_percent               = 0
  max_resource_percent_per_request   = 3
  min_resource_percent_per_request   = 3
  query_execution_timeout_in_seconds = 0
}


resource "azurerm_synapse_sql_pool_workload_classifier" "test" {
  name              = "acctestWChho4p"
  workload_group_id = azurerm_synapse_sql_pool_workload_group.test.id

  member_name = "dbo"
}


resource "azurerm_synapse_sql_pool_workload_classifier" "import" {
  name              = azurerm_synapse_sql_pool_workload_classifier.test.name
  workload_group_id = azurerm_synapse_sql_pool_workload_classifier.test.workload_group_id
  member_name       = "dbo"
}
