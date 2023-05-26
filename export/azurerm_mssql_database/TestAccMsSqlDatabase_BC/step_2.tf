

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-230526085528844613"
  location = "westeurope"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-230526085528844613"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}


resource "azurerm_mssql_database" "test" {
  name           = "acctest-db-230526085528844613"
  server_id      = azurerm_mssql_server.test.id
  read_scale     = false
  sku_name       = "BC_Gen5_2"
  zone_redundant = false
}
