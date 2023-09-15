
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-230915024329537251"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacck0ksi"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-230915024329537251"
  storage_account_id = azurerm_storage_account.test.id
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw230915024329537251"
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
  name                 = "acctestSPk0ksi"
  synapse_workspace_id = azurerm_synapse_workspace.test.id
  sku_name             = "DW500c"
  create_mode          = "Default"
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  data_encrypted       = true

  tags = {
    ENV = "Test"
  }
}
