

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-230203064254857120"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc6q3p1"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-230203064254857120"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw230203064254857120"
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
  name                 = "acctestSP6q3p1"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  sku_name             = "DW100c"
  create_mode          = "Default"
}


resource "azurerm_synapse_sql_pool" "import" {
  name                 = azurerm_synapse_sql_pool.test.name
  synapse_workspace_id = azurerm_synapse_sql_pool.test.synapse_workspace_id
  sku_name             = azurerm_synapse_sql_pool.test.sku_name
  create_mode          = azurerm_synapse_sql_pool.test.create_mode
}
