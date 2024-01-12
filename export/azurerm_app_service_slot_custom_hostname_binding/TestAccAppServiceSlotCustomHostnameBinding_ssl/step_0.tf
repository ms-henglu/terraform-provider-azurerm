
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112035346414513"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-240112035346414513"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "accestAS-240112035346414513"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}

resource "azurerm_app_service_slot" "test" {
  name                = "staging"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_name    = azurerm_app_service.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}

data "azurerm_dns_zone" "test" {
  name                = "ARM_TEST_DNS_ZONE"
  resource_group_name = "ARM_TEST_DATA_RESOURCE_GROUP"
}

resource "azurerm_dns_txt_record" "test" {
  name                = join(".", ["asuid", azurerm_app_service_slot.test.name, azurerm_app_service.test.name])
  zone_name           = data.azurerm_dns_zone.test.name
  resource_group_name = data.azurerm_dns_zone.test.resource_group_name
  ttl                 = 300

  record {
    value = azurerm_app_service.test.custom_domain_verification_id
  }
}

data "azurerm_client_config" "test" {
}

resource "azurerm_key_vault" "test" {
  name                = "acctASwqe81"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.test.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id               = data.azurerm_client_config.test.tenant_id
    object_id               = data.azurerm_client_config.test.object_id
    secret_permissions      = ["Delete", "Get", "Set"]
    certificate_permissions = ["Create", "Delete", "Get", "Import", "Purge"]
  }
}

resource "azurerm_key_vault_certificate" "test" {
  name         = "acctest-AS-240112035346414513"
  key_vault_id = azurerm_key_vault.test.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "digitalSignature",
        "keyEncipherment",
      ]

      subject            = "CN=staging.accestAS-240112035346414513.ARM_TEST_DNS_ZONE"
      validity_in_months = 12
    }
  }
}

data "azurerm_key_vault_secret" "test" {
  name         = azurerm_key_vault_certificate.test.name
  key_vault_id = azurerm_key_vault.test.id
}

resource "azurerm_app_service_certificate" "test" {
  name                = "acctestCert-240112035346414513"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  pfx_blob            = data.azurerm_key_vault_secret.test.value
}

resource "azurerm_app_service_slot_custom_hostname_binding" "test" {
  app_service_slot_id = azurerm_app_service_slot.test.id
  hostname            = "staging.accestAS-240112035346414513.ARM_TEST_DNS_ZONE"
  ssl_state           = "SniEnabled"
  thumbprint          = azurerm_app_service_certificate.test.thumbprint

  depends_on = [azurerm_dns_txt_record.test]
}
