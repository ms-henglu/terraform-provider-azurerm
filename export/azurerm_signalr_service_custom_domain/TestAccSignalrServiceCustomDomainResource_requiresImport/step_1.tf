

provider "azurerm" {
  features {}
}
data "azurerm_client_config" "current" {
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728033109805533"
  location = "West Europe"
}

resource "azurerm_signalr_service" "test" {
  name                = "acctestSignalR-rrc"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku {
    name     = "Premium_P1"
    capacity = 1
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_dns_zone" "test" {
  name                = "tftestzone.com"
  resource_group_name = azurerm_resource_group.test.name
  depends_on = [
    azurerm_signalr_service.test,
    azurerm_signalr_service_custom_certificate.test
  ]
}

resource "azurerm_dns_cname_record" "test" {
  name                = "signalr"
  resource_group_name = azurerm_resource_group.test.name
  zone_name           = azurerm_dns_zone.test.name
  ttl                 = 3600
  record              = azurerm_signalr_service.test.hostname
}

resource "azurerm_key_vault" "test" {
  name                       = "acctestkeyvault6c7fr"
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
    object_id = azurerm_signalr_service.test.identity.0.principal_id
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
  name         = "acctestcert6c7fr"
  key_vault_id = azurerm_key_vault.test.id
  certificate {
    contents = filebase64("testdata/tftestzonecom.pfx")
    password = ""
  }
}

resource "azurerm_signalr_service_custom_certificate" "test" {
  name                  = "signalr-cert-6c7fr"
  signalr_service_id    = azurerm_signalr_service.test.id
  custom_certificate_id = azurerm_key_vault_certificate.test.id
  depends_on            = [azurerm_key_vault.test]
}

resource "azurerm_signalr_service_custom_domain" "test" {
  name                          = "signalrcustom-domain-6c7fr"
  signalr_service_id            = azurerm_signalr_service.test.id
  domain_name                   = "signalr.${azurerm_dns_zone.test.name}"
  signalr_custom_certificate_id = azurerm_signalr_service_custom_certificate.test.id
  depends_on                    = [azurerm_dns_cname_record.test]
}


resource "azurerm_signalr_service_custom_domain" "import" {
  name                          = azurerm_signalr_service_custom_domain.test.name
  signalr_service_id            = azurerm_signalr_service_custom_domain.test.signalr_service_id
  domain_name                   = azurerm_signalr_service_custom_domain.test.domain_name
  signalr_custom_certificate_id = azurerm_signalr_service_custom_domain.test.signalr_custom_certificate_id
}
