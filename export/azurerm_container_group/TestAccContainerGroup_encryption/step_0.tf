
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060849024177"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "test" {
  name                = "acc-230922060849024177"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.test.id
  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Update",
    "GetRotationPolicy",
  ]

  secret_permissions = [
    "Get",
    "Delete",
    "Set",
  ]
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_key" "test" {
  name         = "key-230922060849024177"
  key_vault_id = azurerm_key_vault.test.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  depends_on = [azurerm_key_vault_access_policy.terraform]
}

data "azuread_service_principal" "test" {
  display_name = "Azure Container Instance Service"
}

resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.test.id
  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
    "GetRotationPolicy",
  ]

  tenant_id  = data.azurerm_client_config.current.tenant_id
  object_id  = data.azuread_service_principal.test.object_id
  depends_on = [azurerm_key_vault_access_policy.terraform]
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroup-230922060849024177"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "Public"
  os_type             = "Linux"

  container {
    name   = "hw"
    image  = "ubuntu:20.04"
    cpu    = "0.5"
    memory = "0.5"
    ports {
      port     = 80
      protocol = "TCP"
    }
  }
  key_vault_key_id = azurerm_key_vault_key.test.id
  depends_on       = [azurerm_key_vault_access_policy.test]
}
