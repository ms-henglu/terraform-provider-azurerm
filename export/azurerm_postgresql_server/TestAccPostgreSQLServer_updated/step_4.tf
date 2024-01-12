
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-240112034955574212"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "accsa240112034955574212"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_postgresql_server" "test" {
  name                = "acctest-psql-server-240112034955574212"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!updated"

  sku_name   = "GP_Gen5_4"
  version    = "9.6"
  storage_mb = 640000

  backup_retention_days        = 14
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
  ssl_minimal_tls_version_enforced  = "TLSEnforcementDisabled"

  threat_detection_policy {
    enabled              = true
    disabled_alerts      = ["Sql_Injection"]
    email_account_admins = true
    email_addresses      = ["kt@example.com"]

    retention_days = 7
  }
}
