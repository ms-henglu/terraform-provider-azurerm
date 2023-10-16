

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034356082014"
  location = "West Europe"
}

resource "azurerm_mysql_server" "test" {
  name                = "acctestpsqlsvr-231016034356082014"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "GP_Gen5_2"

  storage_mb                   = 51200
  geo_redundant_backup_enabled = false
  backup_retention_days        = 7

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "5.7"
  ssl_enforcement_enabled      = true
}

resource "azurerm_mysql_database" "test" {
  name                = "acctestdb_231016034356082014"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_mysql_server.test.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}


resource "azurerm_mysql_database" "import" {
  name                = azurerm_mysql_database.test.name
  resource_group_name = azurerm_mysql_database.test.resource_group_name
  server_name         = azurerm_mysql_database.test.server_name
  charset             = azurerm_mysql_database.test.charset
  collation           = azurerm_mysql_database.test.collation
}
