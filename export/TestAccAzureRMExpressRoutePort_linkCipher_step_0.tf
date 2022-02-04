

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204093347262213"
  location = "West Europe"
}


data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest122020413"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_key_vault" "test" {
  name                     = "acctestKv-22020413"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "premium"
  soft_delete_enabled      = true
  purge_protection_enabled = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.test.principal_id
    secret_permissions = [
      "get",
    ]
  }
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "get",
      "set",
      "delete",
      "purge"
    ]
  }
}

resource "azurerm_key_vault_secret" "cak" {
  name         = "cak"
  value        = "ead3664f508eb06c40ac7104cdae4ce5"
  key_vault_id = azurerm_key_vault.test.id
}

resource "azurerm_key_vault_secret" "ckn" {
  name         = "ckn"
  value        = "dffafc8d7b9a43d5b9a3dfbbf6a30c16"
  key_vault_id = azurerm_key_vault.test.id
}

resource "azurerm_express_route_port" "test" {
  name                = "acctestERP-22020413"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  peering_location    = "CDC-Canberra2"
  bandwidth_in_gbps   = 10
  encapsulation       = "Dot1Q"
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
  link1 {
    macsec_cipher                 = "GcmAes256"
    macsec_ckn_keyvault_secret_id = azurerm_key_vault_secret.ckn.id
    macsec_cak_keyvault_secret_id = azurerm_key_vault_secret.cak.id
  }
  link2 {
    macsec_cipher                 = "GcmAes128"
    macsec_ckn_keyvault_secret_id = azurerm_key_vault_secret.ckn.id
    macsec_cak_keyvault_secret_id = azurerm_key_vault_secret.cak.id
  }
}
