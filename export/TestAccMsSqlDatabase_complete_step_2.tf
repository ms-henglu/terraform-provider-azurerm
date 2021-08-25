

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-210825045035682729"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctest-sqlserver-210825045035682729"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name         = "acctest-db-210825045035682729"
  server_id    = azurerm_sql_server.test.id
  collation    = "SQL_AltDiction_CP850_CI_AI"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "GP_Gen5_2"

  tags = {
    ENV = "Staging"
  }
}
