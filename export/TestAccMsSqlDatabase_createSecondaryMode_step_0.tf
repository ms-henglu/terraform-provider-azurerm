


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-210928055715817193"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctest-sqlserver-210928055715817193"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name         = "acctest-db-210928055715817193"
  server_id    = azurerm_sql_server.test.id
  collation    = "SQL_AltDiction_CP850_CI_AI"
  license_type = "BasePrice"
  max_size_gb  = 1
  sample_name  = "AdventureWorksLT"
  sku_name     = "GP_Gen5_2"

  tags = {
    ENV = "Test"
  }
}


resource "azurerm_resource_group" "second" {
  name     = "acctestRG-mssql2-210928055715817193"
  location = "West US 2"
}

resource "azurerm_sql_server" "second" {
  name                         = "acctest-sqlserver2-210928055715817193"
  resource_group_name          = azurerm_resource_group.second.name
  location                     = azurerm_resource_group.second.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_mssql_database" "secondary" {
  name                        = "acctest-dbs-210928055715817193"
  server_id                   = azurerm_sql_server.second.id
  create_mode                 = "Secondary"
  creation_source_database_id = azurerm_mssql_database.test.id

}
