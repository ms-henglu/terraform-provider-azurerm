

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-240105061208225609"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-240105061208225609"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_storage_account" "test" {
  name                     = "accsa240105061208225609"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "bacpac"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "test" {
  name                   = "test.bacpac"
  storage_account_name   = azurerm_storage_account.test.name
  storage_container_name = azurerm_storage_container.test.name
  type                   = "Block"
  source                 = "testdata/sql_import.bacpac"
}

resource "azurerm_sql_firewall_rule" "test" {
  name                = "allowazure"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_mssql_server.test.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_mssql_database" "test" {
  name      = "acctest-db-240105061208225609"
  server_id = azurerm_mssql_server.test.id

  import {
    storage_uri                  = azurerm_storage_blob.test.url
    storage_key                  = azurerm_storage_account.test.primary_access_key
    storage_key_type             = "StorageAccessKey"
    administrator_login          = azurerm_mssql_server.test.administrator_login
    administrator_login_password = azurerm_mssql_server.test.administrator_login_password
    authentication_type          = "Sql"
  }

  timeouts {
    create = "10h"
  }
}
