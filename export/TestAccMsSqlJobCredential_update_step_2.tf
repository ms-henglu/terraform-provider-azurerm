
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-jobcredential-211013072146541139"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestmssqlserver211013072146541139"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "4dministr4t0r"
  administrator_login_password = "superSecur3!!!"
}

resource "azurerm_mssql_database" "test" {
  name      = "acctestmssqldb211013072146541139"
  server_id = azurerm_mssql_server.test.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  sku_name  = "S1"
}

resource "azurerm_mssql_job_agent" "test" {
  name        = "acctestmssqljobagent211013072146541139"
  location    = azurerm_resource_group.test.location
  database_id = azurerm_mssql_database.test.id
}

resource "azurerm_mssql_job_credential" "test" {
  name         = "acctestmssqljobcredential211013072146541139"
  job_agent_id = azurerm_mssql_job_agent.test.id
  username     = "test1"
  password     = "test1"
}
