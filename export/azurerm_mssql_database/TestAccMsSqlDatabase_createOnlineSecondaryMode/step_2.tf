


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-221222035027002880"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-221222035027002880"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name         = "acctest-db-221222035027002880"
  server_id    = azurerm_mssql_server.test.id
  collation    = "SQL_AltDiction_CP850_CI_AI"
  license_type = "BasePrice"
  max_size_gb  = 1
  sample_name  = "AdventureWorksLT"
  sku_name     = "GP_Gen5_2"

  maintenance_configuration_name = azurerm_resource_group.test.location == "westeurope" ? "SQL_WestEurope_DB_2" : "SQL_Default"

  storage_account_type = "Local"

  tags = {
    ENV = "Test"
  }
}


resource "azurerm_resource_group" "second" {
  name     = "acctestRG-mssql2-221222035027002880"
  location = "West US 2"
}

resource "azurerm_mssql_server" "second" {
  name                         = "acctest-sqlserver2-221222035027002880"
  resource_group_name          = azurerm_resource_group.second.name
  location                     = azurerm_resource_group.second.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_mssql_database" "secondary" {
  name                        = "acctest-dbs-221222035027002880"
  server_id                   = azurerm_mssql_server.second.id
  create_mode                 = "OnlineSecondary"
  creation_source_database_id = azurerm_mssql_database.test.id

  tags = {
    tag = "test2"
  }
}
