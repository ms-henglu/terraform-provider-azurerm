


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-221111013930817133"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-221111013930817133"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name      = "acctest-db-221111013930817133"
  server_id = azurerm_mssql_server.test.id
}


resource "azurerm_mssql_database" "pitr" {
  name                        = "acctest-dbp-221111013930817133"
  server_id                   = azurerm_mssql_server.test.id
  create_mode                 = "PointInTimeRestore"
  restore_point_in_time       = "2022-11-11T01:48:30Z"
  creation_source_database_id = azurerm_mssql_database.test.id

}
