
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230519075153618239"
  location = "West Europe"
}

resource "azurerm_mariadb_server" "test" {
  name                = "acctestmariadbsvr-230519075153618239"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 51200
  geo_redundant_backup_enabled = false
  backup_retention_days        = 7

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "10.2"
  ssl_enforcement_enabled      = true
}

resource "azurerm_mariadb_database" "test" {
  name                = "acctestmariadb_230519075153618239"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_mariadb_server.test.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}
