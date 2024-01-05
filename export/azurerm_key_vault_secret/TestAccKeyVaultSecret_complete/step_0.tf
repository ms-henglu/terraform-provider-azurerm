
provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105064005659113"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "acctestkv-nyxdr"
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
  name            = "secret-nyxdr"
  value           = "<rick><morty /></rick>"
  key_vault_id    = azurerm_key_vault.test.id
  content_type    = "application/xml"
  not_before_date = "2019-01-01T01:02:03Z"
  expiration_date = "2020-01-01T01:02:03Z"

  tags = {
    "hello" = "world"
  }
}
