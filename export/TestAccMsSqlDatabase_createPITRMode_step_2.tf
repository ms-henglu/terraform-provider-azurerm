


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-210928055715813539"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctest-sqlserver-210928055715813539"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name      = "acctest-db-210928055715813539"
  server_id = azurerm_sql_server.test.id
}


resource "azurerm_mssql_database" "pitr" {
  name                        = "acctest-dbp-210928055715813539"
  server_id                   = azurerm_sql_server.test.id
  create_mode                 = "PointInTimeRestore"
  restore_point_in_time       = "2021-09-28T06:04:15Z"
  creation_source_database_id = azurerm_mssql_database.test.id

}
