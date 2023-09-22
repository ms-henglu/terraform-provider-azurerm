

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922062018252712"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccq2em9"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

data "azurerm_client_config" "current" {
}

resource "azurerm_role_assignment" "storageAccountRoleAssignment" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}


resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "fstest"
  storage_account_id = azurerm_storage_account.test.id
  depends_on = [
    azurerm_role_assignment.storageAccountRoleAssignment
  ]
}


provider "azuread" {}

resource "azuread_application" "test" {
  display_name = "acctestspa230922062018252712"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_storage_data_lake_gen2_path" "test" {
  storage_account_id = azurerm_storage_account.test.id
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.test.name
  path               = "testpath"
  resource           = "directory"
  ace {
    type        = "user"
    permissions = "r-x"
  }
  ace {
    type        = "user"
    id          = azuread_service_principal.test.object_id
    permissions = "r-x"
  }
  ace {
    type        = "group"
    permissions = "-wx"
  }
  ace {
    type        = "mask"
    permissions = "--x"
  }
  ace {
    type        = "other"
    permissions = "--x"
  }
  ace {
    scope       = "default"
    type        = "user"
    permissions = "r-x"
  }
  ace {
    scope       = "default"
    type        = "user"
    id          = azuread_service_principal.test.object_id
    permissions = "r-x"
  }
  ace {
    scope       = "default"
    type        = "group"
    permissions = "-wx"
  }
  ace {
    scope       = "default"
    type        = "mask"
    permissions = "--x"
  }
  ace {
    scope       = "default"
    type        = "other"
    permissions = "--x"
  }
}
