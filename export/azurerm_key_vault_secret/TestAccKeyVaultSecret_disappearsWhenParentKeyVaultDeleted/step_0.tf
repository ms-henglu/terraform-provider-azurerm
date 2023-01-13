
provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230113181236462307"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "acctestkv-bq9li"
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
  name         = "secret-bq9li"
  value        = "rick-and-morty"
  key_vault_id = azurerm_key_vault.test.id
}
