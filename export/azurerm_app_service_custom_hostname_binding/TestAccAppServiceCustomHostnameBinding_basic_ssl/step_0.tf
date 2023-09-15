
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024406986698"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-230915024406986698"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "ARM_TEST_APP_SERVICE"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}

data "azurerm_client_config" "test" {
}

resource "azurerm_key_vault" "test" {
  name                = "acct-230915024406986698"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.test.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id               = data.azurerm_client_config.test.tenant_id
    object_id               = data.azurerm_client_config.test.object_id
    secret_permissions      = ["Delete", "Get", "Set"]
    certificate_permissions = ["Create", "Delete", "Get", "Import"]
  }
}

resource "azurerm_key_vault_certificate" "test" {
  name         = "acct-230915024406986698"
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

      subject            = "CN=ARM_TEST_DOMAIN"
      validity_in_months = 12
    }
  }
}

data "azurerm_key_vault_secret" "test" {
  name         = azurerm_key_vault_certificate.test.name
  key_vault_id = azurerm_key_vault.test.id
}

resource "azurerm_app_service_certificate" "test" {
  name                = "acctestCert-230915024406986698"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  pfx_blob            = data.azurerm_key_vault_secret.test.value
}

resource "azurerm_app_service_custom_hostname_binding" "test" {
  hostname            = "ARM_TEST_DOMAIN"
  app_service_name    = azurerm_app_service.test.name
  resource_group_name = azurerm_resource_group.test.name
  ssl_state           = "SniEnabled"
  thumbprint          = azurerm_app_service_certificate.test.thumbprint
}
