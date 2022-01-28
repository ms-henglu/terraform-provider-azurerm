


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-220128082718127738"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-220128082718127738"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name      = "acctest-db-220128082718127738"
  server_id = azurerm_mssql_server.test.id
}


resource "azurerm_mssql_database" "import" {
  name      = azurerm_mssql_database.test.name
  server_id = azurerm_mssql_server.test.id
}
