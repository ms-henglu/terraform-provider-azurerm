


provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-240119022113223543"
  location = "West Europe"
}



resource "azurerm_storage_account" "test" {
  name                            = "acctestaccyu7ob"
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

  start  = "2024-01-19T02:21:13Z"
  expiry = "2024-01-20T02:21:13Z"

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
  name                     = "acctest-networkfw-Policy-240119022113223543"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
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
    servers       = ["1.1.1.1", "3.3.3.3", "2.2.2.2"]
    proxy_enabled = true
  }
  tags = {
    env = "Test"
  }
}
