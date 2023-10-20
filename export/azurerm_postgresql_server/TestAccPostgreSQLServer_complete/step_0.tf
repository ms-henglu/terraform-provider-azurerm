
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-231020041657726425"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acct231020041657726425"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_postgresql_server" "test" {
  name                = "acctest-psql-server-231020041657726425"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!updated"

  sku_name   = "GP_Gen5_4"
  version    = "9.6"
  storage_mb = 640000

  backup_retention_days        = 7
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = true

  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"

  threat_detection_policy {
    enabled                    = true
    disabled_alerts            = ["Sql_Injection", "Data_Exfiltration"]
    email_account_admins       = true
    email_addresses            = ["kt@example.com", "admin@example.com"]
    storage_account_access_key = azurerm_storage_account.test.primary_access_key
    retention_days             = 7
  }
  tags = {
    "ENV" = "test"
  }
}
