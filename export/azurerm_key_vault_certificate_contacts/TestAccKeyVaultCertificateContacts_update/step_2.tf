

provider "azurerm" {
  features {
    key_vault {
      recover_soft_deleted_key_vaults    = false
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112224637642354"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "acctestkv-kwm66"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  lifecycle {
    ignore_changes = [
      contact
    ]
  }
}

resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.test.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  certificate_permissions = [
    "ManageContacts",
  ]

  key_permissions = [
    "Create",
  ]

  secret_permissions = [
    "Set",
  ]
}


resource "azurerm_key_vault_certificate_contacts" "test" {
  key_vault_id = azurerm_key_vault.test.id

  contact {
    email = "example@example.com"
    name  = "example"
    phone = "01234567890"
  }

  contact {
    email = "example2@example.com"
    name  = "example2"
  }

  depends_on = [
    azurerm_key_vault_access_policy.test
  ]
}
