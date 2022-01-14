

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-220114064741484490"
  location = "East US"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccx60hf"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-220114064741484490"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw220114064741484490"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
}


resource "azurerm_synapse_spark_pool" "test" {
  name                      = "acctestSSPx60hf"
  synapse_workspace_id      = azurerm_synapse_workspace.test.id
  node_size_family          = "MemoryOptimized"
  node_size                 = "XXXLarge"
  node_count                = 3
  compute_isolation_enabled = true
}
