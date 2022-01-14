


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-220114014906399128"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacci79au"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-220114014906399128"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw220114014906399128"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
}

resource "azurerm_synapse_sql_pool" "test" {
  name                 = "acctestSPi79au"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  sku_name             = "DW100c"
  create_mode          = "Default"
}


resource "azurerm_synapse_sql_pool_workload_group" "test" {
  name                             = "acctestWGi79au"
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
