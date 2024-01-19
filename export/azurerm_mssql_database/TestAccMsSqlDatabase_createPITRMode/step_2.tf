


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-240119025436766687"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-240119025436766687"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name      = "acctest-db-240119025436766687"
  server_id = azurerm_mssql_server.test.id
}


resource "azurerm_mssql_database" "pitr" {
  name                        = "acctest-dbp-240119025436766687"
  server_id                   = azurerm_mssql_server.test.id
  create_mode                 = "PointInTimeRestore"
  restore_point_in_time       = "2024-01-19T03:07:36Z"
  creation_source_database_id = azurerm_mssql_database.test.id

}
