

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-220627134803422282"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctest-sqlserver-220627134803422282"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name                        = "acctest-db-220627134803422282"
  server_id                   = azurerm_sql_server.test.id
  auto_pause_delay_in_minutes = 90
  min_capacity                = 1.25
  sku_name                    = "GP_S_Gen5_2"
}
