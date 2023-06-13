
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-230613072306945749"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-230613072306945749"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name      = "acctest-db-230613072306945749"
  server_id = azurerm_mssql_server.test.id
}

resource "azurerm_mssql_database" "restore" {
  name                        = "acctest-dbr-230613072306945749"
  server_id                   = azurerm_mssql_server.test.id
  create_mode                 = "Restore"
  restore_dropped_database_id = azurerm_mssql_server.test.restorable_dropped_database_ids[0]
}
