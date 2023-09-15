
provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023603508813"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "acctestkv-1b9bi"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
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
  name         = "key-1b9bi"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "EC"
  key_size     = 2048

  key_opts = [
    "sign",
    "verify",
  ]
}
