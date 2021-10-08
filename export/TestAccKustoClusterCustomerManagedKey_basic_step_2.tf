
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044542497631"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                     = "acctestkvy6fus"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  soft_delete_enabled      = true
  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "cluster" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = azurerm_kusto_cluster.test.identity.0.tenant_id
  object_id    = azurerm_kusto_cluster.test.identity.0.principal_id

  key_permissions = ["get", "unwrapkey", "wrapkey"]
}

resource "azurerm_key_vault_access_policy" "client" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "create",
    "delete",
    "get",
    "list",
    "purge",
    "recover",
  ]
}

resource "azurerm_key_vault_key" "first" {
  name         = "test"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]

  depends_on = [
    azurerm_key_vault_access_policy.client,
    azurerm_key_vault_access_policy.cluster,
  ]
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkcy6fus"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }

  identity {
    type = "SystemAssigned"
  }
}
