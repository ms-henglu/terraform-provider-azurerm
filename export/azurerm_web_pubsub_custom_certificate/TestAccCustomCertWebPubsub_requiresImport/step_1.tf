

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025325778002"
  location = "West Europe"
}

resource "azurerm_web_pubsub" "test" {
  name                = "acctestWebPubsub-230825025325778002"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku      = "Premium_P1"
  capacity = 1


  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault" "test" {
  name                       = "acctestkeyvaultffamo"
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

resource "azurerm_dns_zone" "test" {
  name                = "wpstftestzone.com"
  resource_group_name = azurerm_resource_group.test.name
  depends_on = [
    azurerm_web_pubsub.test
  ]
}

resource "azurerm_dns_cname_record" "test" {
  name                = "wps"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 3600
  record              = azurerm_web_pubsub.test.hostname
}

resource "azurerm_key_vault_certificate" "test" {
  name         = "acctestcertffamo"
  key_vault_id = azurerm_key_vault.test.id

  certificate {
    contents = filebase64("testdata/wpstftestzone.pfx")
    password = ""
  }
}

resource "azurerm_web_pubsub_custom_certificate" "test" {
  name                  = "webpubsub-cert-ffamo"
  web_pubsub_id         = azurerm_web_pubsub.test.id
  custom_certificate_id = azurerm_key_vault_certificate.test.id

  depends_on = [azurerm_key_vault.test]
}


resource "azurerm_web_pubsub_custom_certificate" "import" {
  name                  = azurerm_web_pubsub_custom_certificate.test.name
  web_pubsub_id         = azurerm_web_pubsub_custom_certificate.test.web_pubsub_id
  custom_certificate_id = azurerm_web_pubsub_custom_certificate.test.custom_certificate_id
}
