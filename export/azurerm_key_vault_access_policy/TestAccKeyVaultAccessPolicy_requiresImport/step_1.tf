

provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071937371090"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "acctestkv-te2yn"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}


resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.test.id

  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
    "Set",
  ]

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
}


resource "azurerm_key_vault_access_policy" "import" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = azurerm_key_vault_access_policy.test.tenant_id
  object_id    = azurerm_key_vault_access_policy.test.object_id

  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
    "Set",
  ]
}
