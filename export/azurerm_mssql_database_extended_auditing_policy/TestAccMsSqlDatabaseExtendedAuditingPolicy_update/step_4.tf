

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-230804030340596296"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-230804030340596296"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "AdminPassword123!"
}

resource "azurerm_mssql_database" "test" {
  name      = "acctest-db-230804030340596296"
  server_id = azurerm_mssql_server.test.id
}

resource "azurerm_mssql_database_extended_auditing_policy" "test" {
  database_id = azurerm_mssql_database.test.id
  enabled     = false
}

