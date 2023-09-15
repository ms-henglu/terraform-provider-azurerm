


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-230915024329529896"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacccqa20"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-230915024329529896"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw230915024329529896"
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
  name                 = "acctestSSPcqa20"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  node_size_family     = "MemoryOptimized"
  node_size            = "Small"
  node_count           = 3
}


resource "azurerm_synapse_spark_pool" "import" {
  name                 = azurerm_synapse_spark_pool.test.name
  synapse_workspace_id = azurerm_synapse_spark_pool.test.synapse_workspace_id
  node_size_family     = azurerm_synapse_spark_pool.test.node_size_family
  node_size            = azurerm_synapse_spark_pool.test.node_size
  node_count           = azurerm_synapse_spark_pool.test.node_count
}
