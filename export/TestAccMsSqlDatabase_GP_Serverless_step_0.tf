

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-210924011242556065"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctest-sqlserver-210924011242556065"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name                        = "acctest-db-210924011242556065"
  server_id                   = azurerm_sql_server.test.id
  auto_pause_delay_in_minutes = 70
  min_capacity                = 0.75
  sku_name                    = "GP_S_Gen5_2"
}
