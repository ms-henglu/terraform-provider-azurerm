


provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-231218072719601489"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccwl3ro"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-231218072719601489"
  storage_account_id = azurerm_storage_account.test.id
}


data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestuaid231218072719601489"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw231218072719601489"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}


resource "azurerm_synapse_workspace" "import" {
  name                                 = azurerm_synapse_workspace.test.name
  resource_group_name                  = azurerm_synapse_workspace.test.resource_group_name
  location                             = azurerm_synapse_workspace.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_synapse_workspace.test.storage_data_lake_gen2_filesystem_id
  sql_administrator_login              = azurerm_synapse_workspace.test.sql_administrator_login
  sql_administrator_login_password     = azurerm_synapse_workspace.test.sql_administrator_login_password

  identity {
    type = "SystemAssigned"
  }
}
