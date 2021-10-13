


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-211013072146531543"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-211013072146531543"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name         = "acctest-db-211013072146531543"
  server_id    = azurerm_mssql_server.test.id
  collation    = "SQL_AltDiction_CP850_CI_AI"
  license_type = "BasePrice"
  max_size_gb  = 1
  sample_name  = "AdventureWorksLT"
  sku_name     = "GP_Gen5_2"

  tags = {
    ENV = "Test"
  }
}


resource "azurerm_mssql_database" "copy" {
  name                        = "acctest-dbc-211013072146531543"
  server_id                   = azurerm_mssql_server.test.id
  create_mode                 = "Copy"
  creation_source_database_id = azurerm_mssql_database.test.id
}
