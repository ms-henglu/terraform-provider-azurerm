

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-230127045801098925"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-230127045801098925"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name         = "acctest-db-230127045801098925"
  server_id    = azurerm_mssql_server.test.id
  collation    = "SQL_AltDiction_CP850_CI_AI"
  license_type = "BasePrice"
  max_size_gb  = 1
  sample_name  = "AdventureWorksLT"
  sku_name     = "GP_Gen5_2"

  maintenance_configuration_name = "SQL_Default"

  storage_account_type = "Local"

  tags = {
    ENV = "Test"
  }
}
