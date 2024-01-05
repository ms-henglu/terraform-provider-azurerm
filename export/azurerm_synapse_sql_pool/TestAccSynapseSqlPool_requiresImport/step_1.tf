

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-240105061713852774"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccqyq69"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-240105061713852774"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw240105061713852774"
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
  name                 = "acctestSPqyq69"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  sku_name             = "DW100c"
  create_mode          = "Default"
  storage_account_type = "GRS"
}


resource "azurerm_synapse_sql_pool" "import" {
  name                 = azurerm_synapse_sql_pool.test.name
  synapse_workspace_id = azurerm_synapse_sql_pool.test.synapse_workspace_id
  sku_name             = azurerm_synapse_sql_pool.test.sku_name
  create_mode          = azurerm_synapse_sql_pool.test.create_mode
  storage_account_type = "GRS"
}
