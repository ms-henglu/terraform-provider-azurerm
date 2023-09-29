

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-230929065836867997"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccylg0i"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-230929065836867997"
  storage_account_id = azurerm_storage_account.test.id
}


data "azurerm_client_config" "current" {}

resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw230929065836867997"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"

  azure_devops_repo {
    account_name    = "myorg"
    project_name    = "myproj"
    repository_name = "myrepo"
    branch_name     = "dev"
    root_folder     = "/"
    tenant_id       = data.azurerm_client_config.current.tenant_id
  }

  identity {
    type = "SystemAssigned"
  }
}
