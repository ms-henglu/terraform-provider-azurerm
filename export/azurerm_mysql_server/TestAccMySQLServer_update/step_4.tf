
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysql-240119025452519636"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "accsa240119025452519636"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_mysql_server" "test" {
  name                             = "acctestmysqlsvr-240119025452519636"
  location                         = azurerm_resource_group.test.location
  resource_group_name              = azurerm_resource_group.test.name
  sku_name                         = "GP_Gen5_2"
  administrator_login              = "acctestun"
  administrator_login_password     = "H@Sh1CoR3!updated"
  auto_grow_enabled                = true
  backup_retention_days            = 7
  create_mode                      = "Default"
  geo_redundant_backup_enabled     = false
  ssl_enforcement_enabled          = false
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
  storage_mb                       = 51200
  version                          = "8.0"
  threat_detection_policy {
    enabled                    = true
    disabled_alerts            = ["Sql_Injection"]
    email_account_admins       = true
    email_addresses            = ["pearcec@example.com"]
    retention_days             = 7
    storage_endpoint           = azurerm_storage_account.test.primary_blob_endpoint
    storage_account_access_key = azurerm_storage_account.test.primary_access_key
  }
}
