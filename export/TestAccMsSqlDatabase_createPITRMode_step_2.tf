


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-210924004612261797"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctest-sqlserver-210924004612261797"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name      = "acctest-db-210924004612261797"
  server_id = azurerm_sql_server.test.id
}


resource "azurerm_mssql_database" "pitr" {
  name                        = "acctest-dbp-210924004612261797"
  server_id                   = azurerm_sql_server.test.id
  create_mode                 = "PointInTimeRestore"
  restore_point_in_time       = "2021-09-24T00:53:12Z"
  creation_source_database_id = azurerm_mssql_database.test.id

}
