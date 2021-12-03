

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211203014532549859"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacccva3u"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}


provider "azuread" {}

data "azurerm_client_config" "current" {
}

resource "azurerm_role_assignment" "storageAccountRoleAssignment" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azuread_application" "test" {
  display_name = "acctestspa211203014532549859"
}

resource "azuread_service_principal" "test" {
  application_id = azuread_application.test.application_id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "test" {
  name               = "acctest-211203014532549859"
  storage_account_id = azurerm_storage_account.test.id
  ace {
    type        = "user"
    permissions = "rwx"
  }
  ace {
    type        = "user"
    id          = azuread_service_principal.test.object_id
    permissions = "--x"
  }
  ace {
    type        = "group"
    permissions = "r-x"
  }
  ace {
    type        = "mask"
    permissions = "r-x"
  }
  ace {
    type        = "other"
    permissions = "---"
  }
  depends_on = [
    azurerm_role_assignment.storageAccountRoleAssignment,
    azuread_service_principal.test
  ]
}
