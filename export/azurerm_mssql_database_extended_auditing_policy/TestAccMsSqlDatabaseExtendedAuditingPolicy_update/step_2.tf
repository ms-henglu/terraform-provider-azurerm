

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-231016034338804294"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-231016034338804294"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "AdminPassword123!"
}

resource "azurerm_mssql_database" "test" {
  name      = "acctest-db-231016034338804294"
  server_id = azurerm_mssql_server.test.id
}

resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acct4siz2"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_mssql_database_extended_auditing_policy" "test" {
  database_id                             = azurerm_mssql_database.test.id
  storage_endpoint                        = azurerm_storage_account.test.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.test.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 6
  log_monitoring_enabled                  = false
  enabled                                 = true
}
