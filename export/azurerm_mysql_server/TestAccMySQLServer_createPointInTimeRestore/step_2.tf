

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204619263322"
  location = "West Europe"
}

resource "azurerm_mysql_server" "test" {
  name                             = "acctestmysqlsvr-221221204619263322"
  location                         = azurerm_resource_group.test.location
  resource_group_name              = azurerm_resource_group.test.name
  sku_name                         = "GP_Gen5_2"
  administrator_login              = "acctestun"
  administrator_login_password     = "H@Sh1CoR3!"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_1"
  storage_mb                       = 51200
  version                          = "8.0"
}


resource "azurerm_mysql_server" "restore" {
  name                = "acctestmysqlsvr-221221204619263322-restore"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "GP_Gen5_2"
  version             = "8.0"

  create_mode                      = "PointInTimeRestore"
  creation_source_server_id        = azurerm_mysql_server.test.id
  restore_point_in_time            = "2022-12-21T20:57:19Z"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_1"
  storage_mb                       = 51200
}
