
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-jobcredential-220712042553582629"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestmssqlserver220712042553582629"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "4dministr4t0r"
  administrator_login_password = "superSecur3!!!"
}

resource "azurerm_mssql_database" "test" {
  name      = "acctestmssqldb220712042553582629"
  server_id = azurerm_mssql_server.test.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  sku_name  = "S1"
}

resource "azurerm_mssql_job_agent" "test" {
  name        = "acctestmssqljobagent220712042553582629"
  location    = azurerm_resource_group.test.location
  database_id = azurerm_mssql_database.test.id
}

resource "azurerm_mssql_job_credential" "test" {
  name         = "acctestmssqljobcredential220712042553582629"
  job_agent_id = azurerm_mssql_job_agent.test.id
  username     = "test1"
  password     = "test1"
}
