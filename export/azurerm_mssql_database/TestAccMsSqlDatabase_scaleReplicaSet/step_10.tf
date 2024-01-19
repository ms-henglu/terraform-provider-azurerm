

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-240119022502157335"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-240119022502157335"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "primary" {
  name        = "acctest-db-240119022502157335"
  server_id   = azurerm_mssql_server.test.id
  sample_name = "AdventureWorksLT"

  max_size_gb = "2"
  sku_name    = "S2"
}

resource "azurerm_resource_group" "secondary" {
  name     = "acctestRG-mssql2-240119022502157335"
  location = "West US 2"
}

resource "azurerm_mssql_server" "secondary" {
  name                         = "acctest-sqlserver2-240119022502157335"
  resource_group_name          = azurerm_resource_group.secondary.name
  location                     = azurerm_resource_group.secondary.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog12"
}

resource "azurerm_mssql_database" "secondary" {
  name                        = "acctest-db-240119022502157335"
  server_id                   = azurerm_mssql_server.secondary.id
  create_mode                 = "Secondary"
  creation_source_database_id = azurerm_mssql_database.primary.id

  sku_name = "S2"
}
