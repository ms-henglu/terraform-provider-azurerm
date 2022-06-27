


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-220627134803424430"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctest-sqlserver-220627134803424430"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name      = "acctest-db-220627134803424430"
  server_id = azurerm_sql_server.test.id
}


resource "azurerm_mssql_database" "pitr" {
  name                        = "acctest-dbp-220627134803424430"
  server_id                   = azurerm_sql_server.test.id
  create_mode                 = "PointInTimeRestore"
  restore_point_in_time       = "2022-06-27T13:55:03Z"
  creation_source_database_id = azurerm_mssql_database.test.id

}
