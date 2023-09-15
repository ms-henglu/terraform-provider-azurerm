
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PAN-230915023955467246"
  location = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-230915023955467246"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack_certificate" "test" {
  name         = "testacc-palc-230915023955467246"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id
  self_signed  = true
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "test" {
  name                       = "acctestkeyvault8v17h"
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

    key_permissions = [
      "Create",
    ]

    secret_permissions = [
      "Get",
      "Set",
    ]

    storage_permissions = [
      "Set",
    ]
  }
}

resource "azurerm_key_vault_certificate" "trust" {
  name         = "acctesttrust8v17h"
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
      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyEncipherment",
        "keyCertSign",
      ]

      subject            = "CN=hello-world"
      validity_in_months = 12
    }
  }
}

resource "azurerm_key_vault_certificate" "untrust" {
  name         = "acctestuntrust8v17h"
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
      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyEncipherment",
        "keyCertSign",
      ]

      subject            = "CN=hello-world"
      validity_in_months = 12
    }
  }
}

resource "azurerm_palo_alto_local_rulestack_certificate" "trust" {
  name         = "testacc-palcT-230915023955467246"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id

  key_vault_certificate_id = azurerm_key_vault_certificate.trust.versionless_id
}

resource "azurerm_palo_alto_local_rulestack_certificate" "untrust" {
  name         = "testacc-palcU-230915023955467246"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id

  key_vault_certificate_id = azurerm_key_vault_certificate.untrust.versionless_id
}

resource "azurerm_palo_alto_local_rulestack_outbound_trust_certificate_association" "test" {
  certificate_id = azurerm_palo_alto_local_rulestack_certificate.trust.id
}

resource "azurerm_palo_alto_local_rulestack_outbound_untrust_certificate_association" "test" {
  certificate_id = azurerm_palo_alto_local_rulestack_certificate.untrust.id
}


resource "azurerm_palo_alto_local_rulestack_rule" "test" {
  name         = "testacc-palr-230915023955467246"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id
  priority     = 100

  action        = "DenySilent"
  applications  = ["any"]
  audit_comment = "test audit comment"

  category {
    custom_urls = ["web-based-email", "social-networking"]
  }

  description = "Acceptance Test Rule - updated 230915023955467246"

  destination {
    countries = ["US", "GB"]
  }

  logging_enabled = false

  inspection_certificate_id = azurerm_palo_alto_local_rulestack_certificate.test.id

  negate_destination = false
  negate_source      = false

  protocol = "TCP:8080"

  enabled = true

  source {
    countries = ["US", "GB"]
  }

  tags = {
    "acctest" = "true"
    "foo"     = "bar"
  }
}
