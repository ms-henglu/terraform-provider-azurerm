
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-210830084540878071"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccmp6ut"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-210830084540878071"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw210830084540878071"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
}


resource "azurerm_synapse_sql_pool" "test" {
  name                 = "acctestSPmp6ut"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  sku_name             = "DW500c"
  create_mode          = "Default"
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  data_encrypted       = true

  tags = {
    ENV = "Test"
  }
}
