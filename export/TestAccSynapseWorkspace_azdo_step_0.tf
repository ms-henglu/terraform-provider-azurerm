

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-210906022816219597"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacca29my"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-210906022816219597"
  storage_account_id = azurerm_storage_account.test.id
}


resource "azurerm_synapse_workspace" "test" {
  name                                 = "acctestsw210906022816219597"
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
  }
}
