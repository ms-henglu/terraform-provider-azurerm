
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421022935311633"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctestWebPubsub-230421022935311633"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku      = "Premium_P1"
  capacity = 1


  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault" "test" {
  name                       = "acctestkeyvaultozvr0"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = [
      "Create",
      "Delete",
      "Get",
      "Import",
      "Purge",
      "Recover",
      "Update",
      "List",
    ]

    secret_permissions = [
      "Get",
      "Set",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_web_pubsub.test.identity[0].principal_id

    certificate_permissions = [
      "Create",
      "Delete",
      "Get",
      "Import",
      "Purge",
      "Recover",
      "Update",
      "List",
    ]

    secret_permissions = [
      "Get",
      "Set",
    ]
  }
}

resource "azurerm_key_vault_certificate" "test" {
  name         = "acctestcertozvr0"
  key_vault_id = azurerm_key_vault.test.id

  certificate {
    contents = filebase64("testdata/certificate-to-import.pfx")
    password = ""
  }
}

resource "azurerm_web_pubsub_custom_certificate" "test" {
  name                  = "webpubsub-cert-ozvr0"
  web_pubsub_id         = azurerm_web_pubsub.test.id
  custom_certificate_id = azurerm_key_vault_certificate.test.id

  depends_on = [azurerm_key_vault.test]
}
