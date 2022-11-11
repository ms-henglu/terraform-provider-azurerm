

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-221111013930810726"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-221111013930810726"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name         = "acctest-db-221111013930810726"
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
