
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-221221204608590596"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-221221204608590596"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name      = "acctest-db-221221204608590596"
  server_id = azurerm_mssql_server.test.id
}

resource "azurerm_mssql_database" "restore" {
  name                        = "acctest-dbr-221221204608590596"
  server_id                   = azurerm_mssql_server.test.id
  create_mode                 = "Restore"
  restore_dropped_database_id = azurerm_mssql_server.test.restorable_dropped_database_ids[0]
}
