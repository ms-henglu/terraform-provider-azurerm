
provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034112416035"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "acctestkv-u2iqx"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Delete",
      "Get",
      "Purge",
      "Recover",
      "Update",
      "SetRotationPolicy",
      "GetRotationPolicy",
      "Rotate",
    ]

    secret_permissions = [
      "Delete",
      "Get",
      "Set",
    ]
  }

  tags = {
    environment = "Production"
  }
}


resource "azurerm_key_vault_key" "test" {
  name         = "key-u2iqx"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "EC-HSM"
  curve        = "P-521"

  key_opts = [
    "sign",
    "verify",
  ]
}
