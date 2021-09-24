

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-jobagent-210924004612274965"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestmssqlserver210924004612274965"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "4dministr4t0r"
  administrator_login_password = "superSecur3!!!"
}

resource "azurerm_mssql_database" "test" {
  name      = "acctestmssqldb210924004612274965"
  server_id = azurerm_mssql_server.test.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  sku_name  = "S1"
}

resource "azurerm_mssql_job_agent" "test" {
  name        = "acctestmssqljobagent210924004612274965"
  location    = azurerm_resource_group.test.location
  database_id = azurerm_mssql_database.test.id
}


resource "azurerm_mssql_job_agent" "import" {
  name        = azurerm_mssql_job_agent.test.name
  location    = azurerm_resource_group.test.location
  database_id = azurerm_mssql_database.test.id
}
