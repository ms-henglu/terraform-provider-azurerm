
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929065056549824"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "vault230929065056549824"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  public_network_access_enabled = false

  access_policy {
    tenant_id      = data.azurerm_client_config.current.tenant_id
    object_id      = data.azurerm_client_config.current.object_id
    application_id = data.azurerm_client_config.current.client_id

    certificate_permissions = [
      "Get",
    ]

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]
  }

  tags = {
    environment = "Production"
  }
}
