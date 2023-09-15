
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022812173540"
  location = "West Europe"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "test" {
  name                = "acctestKV-w3h7m"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  certificate_permissions = [
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "SetIssuers",
    "Update",
    "Purge",
  ]
  secret_permissions = [
    "Delete",
    "Get",
    "List",
    "Purge",
  ]
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-230915022812173540"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_key_vault_access_policy" "test2" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = azurerm_user_assigned_identity.test.tenant_id
  object_id    = azurerm_user_assigned_identity.test.principal_id
  secret_permissions = [
    "Get",
    "List",
  ]
}

resource "azurerm_key_vault_certificate" "test" {
  depends_on   = [azurerm_key_vault_access_policy.test]
  name         = "acctestKVCert-230915022812173540"
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
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]
      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]
      subject_alternative_names {
        dns_names = ["api.terraform.io"]
      }
      subject            = "CN=api.terraform.io"
      validity_in_months = 1
    }
  }
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230915022812173540"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"

  hostname_configuration {
    proxy {
      host_name                    = "acctestAM-230915022812173540.azure-api.net"
      negotiate_client_certificate = true
    }

    proxy {
      host_name                       = "api.terraform.io"
      key_vault_id                    = azurerm_key_vault_certificate.test.secret_id
      default_ssl_binding             = true
      negotiate_client_certificate    = false
      ssl_keyvault_identity_client_id = azurerm_user_assigned_identity.test.client_id
    }
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }

  depends_on = [azurerm_key_vault_access_policy.test2]
}
