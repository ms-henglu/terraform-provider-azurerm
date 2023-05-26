

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-230526090023544864"
  location = "East US"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccgd8lo"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-230526090023544864"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw230526090023544864"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_synapse_spark_pool" "test" {
  name                      = "acctestSSPgd8lo"
  synapse_workspace_id      = azurerm_synapse_workspace.test.id
  node_size_family          = "MemoryOptimized"
  node_size                 = "XXXLarge"
  node_count                = 3
  compute_isolation_enabled = true
}
