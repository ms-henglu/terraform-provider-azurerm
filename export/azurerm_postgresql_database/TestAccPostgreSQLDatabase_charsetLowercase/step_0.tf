
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-230929065511039448"
  location = "West Europe"
}

resource "azurerm_postgresql_server" "test" {
  name                = "acctest-psql-server-230929065511039448"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "GP_Gen5_2"

  storage_mb                   = 51200
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "9.6"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_database" "test" {
  name                = "acctest_PSQL_db_230929065511039448"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_postgresql_server.test.name
  charset             = "utf8"
  collation           = "English_United States.1252"
}
