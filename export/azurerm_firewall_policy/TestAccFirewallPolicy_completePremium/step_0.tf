



provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-240112034421967383"
  location = "westeurope"
}

resource "azurerm_key_vault" "test" {
  name                            = "tlskv240112034421967383"
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
  name                = "acctestUAI-240112034421967383"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_key_vault_access_policy" "test" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.test.principal_id

  key_permissions = [
    "Create",
    "Get",
  ]

  certificate_permissions = [
    "Create",
    "Get",
    "List",
    "ManageContacts",
  ]

  secret_permissions = [
    "Get",
    "List",
  ]
}

resource "azurerm_key_vault_access_policy" "test2" {
  key_vault_id = azurerm_key_vault.test.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Backup",
    "Create",
    "Delete",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Update"
  ]

  certificate_permissions = [
    "Backup",
    "Create",
    "Get",
    "List",
    "Import",
    "Purge",
    "Delete",
    "Recover",
    "ManageContacts",
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Purge",
    "Delete",
    "Recover"
  ]
}

resource "azurerm_key_vault_certificate" "test" {
  name         = "AzureFirewallPolicyCertificate"
  key_vault_id = azurerm_key_vault.test.id

  certificate {
    contents = filebase64("testdata/certificate.pfx")
    password = "somepassword"
  }

  depends_on = [azurerm_key_vault_access_policy.test, azurerm_key_vault_access_policy.test2]
}



resource "azurerm_storage_account" "test" {
  name                            = "acctestacc7oqf6"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = true
}

resource "azurerm_storage_container" "test" {
  name                  = "test"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "test" {
  name                   = "example.pac"
  storage_account_name   = azurerm_storage_account.test.name
  storage_container_name = azurerm_storage_container.test.name
  type                   = "Block"
  source_content         = "function FindProxyForURL(url, host) { return \"DIRECT\"; }"
}

data "azurerm_storage_account_sas" "test" {
  connection_string = azurerm_storage_account.test.primary_connection_string
  https_only        = true
  signed_version    = "2019-10-10"

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2024-01-12T03:44:21Z"
  expiry = "2024-01-13T03:44:21Z"

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}


resource "azurerm_firewall_policy" "test" {
  name                     = "acctest-networkfw-Policy-240112034421967383"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  sku                      = "Premium"
  threat_intelligence_mode = "Off"
  threat_intelligence_allowlist {
    ip_addresses = ["1.1.1.1", "2.2.2.2", "10.0.0.0/16"]
    fqdns        = ["foo.com", "bar.com"]
  }
  explicit_proxy {
    enabled         = true
    http_port       = 8087
    https_port      = 8088
    enable_pac_file = true
    pac_file_port   = 8089
    pac_file        = "${azurerm_storage_blob.test.id}${data.azurerm_storage_account_sas.test.sas}&sr=b"
  }
  auto_learn_private_ranges_enabled = true
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
    private_ranges = ["172.111.111.111"]
    traffic_bypass {
      name                  = "Name bypass traffic settings"
      description           = "Description bypass traffic settings"
      destination_addresses = []
      source_addresses      = []
      protocol              = "Any"
      destination_ports     = ["*"]
      source_ip_groups = [
        azurerm_ip_group.test_source.id,
      ]
      destination_ip_groups = [
        azurerm_ip_group.test_destination.id,
      ]
    }
  }
  sql_redirect_allowed = true
  identity {
    type = "UserAssigned"
    identity_ids = [
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
