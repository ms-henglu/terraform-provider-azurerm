



provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-KV-240112224637666793"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                       = "acc240112224637666793"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "Create",
      "Delete",
      "Get",
      "Purge",
      "Recover",
      "Update",
      "GetRotationPolicy",
    ]
    secret_permissions = [
      "Delete",
      "Get",
      "Set",
    ]
    certificate_permissions = [
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "Purge",
      "Update"
    ]
  }
  tags = {
    environment = "Production"
  }
}
resource "azurerm_key_vault_certificate" "cert" {
  count        = 3
  name         = "acchsmcert${count.index}"
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
    lifetime_action {
      action {
        action_type = "AutoRenew"
      }
      trigger {
        days_before_expiry = 30
      }
    }
    secret_properties {
      content_type = "application/x-pkcs12"
    }
    x509_certificate_properties {
      extended_key_usage = []
      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]
      subject            = "CN=hello-world"
      validity_in_months = 12
    }
  }
}
resource "azurerm_key_vault_managed_hardware_security_module" "test" {
  name                     = "kvHsm240112224637666793"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku_name                 = "Standard_B1"
  tenant_id                = data.azurerm_client_config.current.tenant_id
  admin_object_ids         = [data.azurerm_client_config.current.object_id]
  purge_protection_enabled = false
  
  security_domain_key_vault_certificate_ids = [for cert in azurerm_key_vault_certificate.cert : cert.id]
  security_domain_quorum 				    = 2

}


locals {
  roleTestName = "c9562a52-2bd9-2671-3d89-cea5b4798a6b"
}

resource "azurerm_key_vault_managed_hardware_security_module_role_definition" "test" {
  name           = local.roleTestName
  vault_base_url = azurerm_key_vault_managed_hardware_security_module.test.hsm_uri
  description    = "desc foo"
  permission {
    data_actions = [
      "Microsoft.KeyVault/managedHsm/keys/read/action",
      "Microsoft.KeyVault/managedHsm/keys/write/action",
      "Microsoft.KeyVault/managedHsm/keys/encrypt/action",
      "Microsoft.KeyVault/managedHsm/keys/create",
      "Microsoft.KeyVault/managedHsm/keys/delete",
    ]
    not_data_actions = [
      "Microsoft.KeyVault/managedHsm/roleAssignments/read/action",
    ]
  }
}
