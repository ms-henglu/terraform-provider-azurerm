
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = "true"
      recover_soft_deleted_key_vaults = true
    }
  }
}


data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034112434539"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "acctestkv-3cl0y"
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

  tags = {
    environment = "Production"
  }
}


resource "azurerm_key_vault_secret" "test" {
  name         = "secret-3cl0y"
  value        = "second"
  key_vault_id = azurerm_key_vault.test.id
}
