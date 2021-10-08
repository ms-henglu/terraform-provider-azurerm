
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-211008045035040267"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccosh20"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-211008045035040267"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw211008045035040267"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
}


resource "azurerm_synapse_sql_pool" "test" {
  name                 = "acctestSPosh20"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  sku_name             = "DW100c"
  create_mode          = "Default"
}
