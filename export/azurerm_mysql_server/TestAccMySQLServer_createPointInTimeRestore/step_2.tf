

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630033629341763"
  location = "West Europe"
}

resource "azurerm_mysql_server" "test" {
  name                             = "acctestmysqlsvr-230630033629341763"
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
  name                = "acctestmysqlsvr-230630033629341763-restore"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "GP_Gen5_2"
  version             = "8.0"

  create_mode                      = "PointInTimeRestore"
  creation_source_server_id        = azurerm_mysql_server.test.id
  restore_point_in_time            = "2023-06-30T03:47:29Z"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_1"
  storage_mb                       = 51200
}
