


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-220826003043764290"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-220826003043764290"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name      = "acctest-db-220826003043764290"
  server_id = azurerm_mssql_server.test.id
}


resource "azurerm_mssql_database" "pitr" {
  name                        = "acctest-dbp-220826003043764290"
  server_id                   = azurerm_mssql_server.test.id
  create_mode                 = "PointInTimeRestore"
  restore_point_in_time       = "2022-08-26T00:39:43Z"
  creation_source_database_id = azurerm_mssql_database.test.id

}
