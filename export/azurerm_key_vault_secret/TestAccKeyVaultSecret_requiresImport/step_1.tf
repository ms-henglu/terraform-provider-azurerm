

provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112224637679207"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "acctestkv-30c74"
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
  name         = "secret-30c74"
  value        = "rick-and-morty"
  key_vault_id = azurerm_key_vault.test.id
}


resource "azurerm_key_vault_secret" "import" {
  name         = azurerm_key_vault_secret.test.name
  value        = azurerm_key_vault_secret.test.value
  key_vault_id = azurerm_key_vault_secret.test.key_vault_id
}
