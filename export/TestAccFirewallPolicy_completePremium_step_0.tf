

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-220107064101319059"
  location = "westeurope"
}

resource "azurerm_key_vault" "test" {
  name                            = "tlskv220107064101319059"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "standard"
}

resource "azurerm_ip_group" "test_source" {
  name                = "acctestIpGroupForFirewallNetworkRulesSource"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  cidrs               = ["1.2.3.4/32", "12.34.56.0/24"]
}

resource "azurerm_ip_group" "test_destination" {
  name                = "acctestIpGroupForFirewallNetworkRulesDestination"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  cidrs               = ["192.168.0.0/25", "192.168.0.192/26"]
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-220107064101319059"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id   = azurerm_key_vault.test.id
  application_id = azurerm_user_assigned_identity.test.client_id
  tenant_id      = data.azurerm_client_config.current.tenant_id
  object_id      = azurerm_user_assigned_identity.test.principal_id

  key_permissions = [
    "backup",
    "create",
    "delete",
    "get",
    "import",
    "list",
    "purge",
    "recover",
    "restore",
    "update"
  ]

  certificate_permissions = [
    "backup",
    "create",
    "get",
    "list",
    "import",
    "purge",
    "delete",
    "recover",
  ]

  secret_permissions = [
    "get",
    "list",
    "set",
    "purge",
    "delete",
    "recover"
  ]
}

resource "azurerm_key_vault_access_policy" "test2" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "backup",
    "create",
    "delete",
    "get",
    "import",
    "list",
    "purge",
    "recover",
    "restore",
    "update"
  ]

  certificate_permissions = [
    "backup",
    "create",
    "get",
    "list",
    "import",
    "purge",
    "delete",
    "recover",
  ]

  secret_permissions = [
    "get",
    "list",
    "set",
    "purge",
    "delete",
    "recover"
  ]
}

resource "azurerm_key_vault_certificate" "test" {
  name         = "AzureFirewallPolicyCertificate"
  key_vault_id = azurerm_key_vault.test.id

  certificate {
    contents = filebase64("testdata/certificate.pfx")
  }

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }

  depends_on = [azurerm_key_vault_access_policy.test2]
}

resource "azurerm_firewall_policy" "test" {
  name                     = "acctest-networkfw-Policy-220107064101319059"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku                      = "Premium"
  threat_intelligence_mode = "Off"
  threat_intelligence_allowlist {
    ip_addresses = ["1.1.1.1", "2.2.2.2", "10.0.0.0/16"]
    fqdns        = ["foo.com", "bar.com"]
  }
  dns {
    servers       = ["1.1.1.1", "2.2.2.2"]
    proxy_enabled = true
  }
  intrusion_detection {
    mode = "Alert"
    signature_overrides {
      state = "Alert"
      id    = "1"
    }
    traffic_bypass {
      name              = "Name bypass traffic settings"
      description       = "Description bypass traffic settings"
      protocol          = "Any"
      destination_ports = ["*"]
      source_ip_groups = [
        azurerm_ip_group.test_source.id,
      ]
      destination_ip_groups = [
        azurerm_ip_group.test_destination.id,
      ]
    }
  }
  identity {
    type = "UserAssigned"
    user_assigned_identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }
  tls_certificate {
    key_vault_secret_id = azurerm_key_vault_certificate.test.secret_id
    name                = azurerm_key_vault_certificate.test.name
  }
  private_ip_ranges = ["172.16.0.0/12", "192.168.0.0/16"]
  tags = {
    env = "Test"
  }
}
