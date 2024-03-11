

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-240311032553402896"
  location = "West Europe"
}

resource "azurerm_storage_account" "first" {
  name                     = "acctestsa16hz1i"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest6hz1i"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_storage_account" "third" {
  name                     = "acctestsa36hz1i"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}

resource "azurerm_role_assignment" "storageAccountRoleAssignment" {
  scope                = azurerm_storage_account.third.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_media_services_account" "test" {
  name                        = "acctestmsa6hz1i"
  location                    = azurerm_resource_group.test.location
  resource_group_name         = azurerm_resource_group.test.name
  storage_authentication_type = "ManagedIdentity"

  storage_account {
    id         = azurerm_storage_account.third.id
    is_primary = true
    managed_identity {
      user_assigned_identity_id    = azurerm_user_assigned_identity.test.id
      use_system_assigned_identity = false
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  tags = {
    environment = "staging"
  }

  depends_on = [
    azurerm_role_assignment.storageAccountRoleAssignment
  ]
}
