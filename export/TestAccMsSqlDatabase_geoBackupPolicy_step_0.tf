

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-210825045035699748"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctest-sqlserver-210825045035699748"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name               = "acctest-db-210825045035699748"
  server_id          = azurerm_sql_server.test.id
  sku_name           = "DW100c"
  geo_backup_enabled = false
}
