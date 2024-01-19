
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LFA-240119024436446456"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsat3z0f"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-240119024436446456"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "S1"
  
}

resource "azurerm_linux_function_app" "test" {
  name                = "acctest-LFA-240119024436446456"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {}
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acct-240119024436446456"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "test" {
  name                       = "acctestkv-t3z0f"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
      "Delete",
      "List",
      "Purge",
      "Recover",
      "Set",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.test.principal_id

    secret_permissions = [
      "Get",
      "List",
    ]
  }

  tags = {
    environment = "AccTest"
  }
}

resource "azurerm_key_vault_secret" "test" {
  name         = "secret-t3z0f"
  value        = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.test.name};AccountKey=${azurerm_storage_account.test.primary_access_key};EndpointSuffix=core.windows.net"
  key_vault_id = azurerm_key_vault.test.id
}

resource "azurerm_linux_function_app_slot" "test" {
  name            = "acctest-LFAS-240119024436446456"
  function_app_id = azurerm_linux_function_app.test.id

  key_vault_reference_identity_id = azurerm_user_assigned_identity.test.id
  storage_key_vault_secret_id     = azurerm_key_vault_secret.test.id

  site_config {}

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}
