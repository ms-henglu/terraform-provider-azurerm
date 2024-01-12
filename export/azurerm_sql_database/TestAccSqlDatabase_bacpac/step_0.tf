
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG_240112225312237281"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "accsa240112225312237281"
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

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver240112225312237281"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_firewall_rule" "test" {
  name                = "allowazure"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_sql_server.test.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_sql_database" "test" {
  name                             = "acctestdb240112225312237281"
  resource_group_name              = azurerm_resource_group.test.name
  server_name                      = azurerm_sql_server.test.name
  location                         = azurerm_resource_group.test.location
  edition                          = "Standard"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  max_size_bytes                   = "1073741824"
  requested_service_objective_name = "S0"

  import {
    storage_uri                  = azurerm_storage_blob.test.url
    storage_key                  = azurerm_storage_account.test.primary_access_key
    storage_key_type             = "StorageAccessKey"
    administrator_login          = azurerm_sql_server.test.administrator_login
    administrator_login_password = azurerm_sql_server.test.administrator_login_password
    authentication_type          = "SQL"
  }
}
