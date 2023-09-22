

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-230922055026998217"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccjmbu7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-230922055026998217"
  storage_account_id = azurerm_storage_account.test.id
}


resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw230922055026998217"
  resource_group_name                  = azurerm_resource_group.test.name
  location                             = azurerm_resource_group.test.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.test.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"

  github_repo {
    account_name    = "myuser"
    git_url         = "https://github.mydomain.com"
    repository_name = "myrepo"
    branch_name     = "dev"
    root_folder     = "/"
    last_commit_id  = "1592393b38543d51feb12714cbd39501d697610c"
  }

  identity {
    type = "SystemAssigned"
  }
}
