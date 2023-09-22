

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061501759675"
  location = "West Europe"
}

resource "azurerm_mariadb_server" "test" {
  name                = "acctestmariadbsvr-230922061501759675"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "B_Gen5_2"
  version             = "10.3"

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"
  ssl_enforcement_enabled      = true
  storage_mb                   = 51200
}


resource "azurerm_mariadb_server" "restore" {
  name                      = "acctestmariadbsvr-230922061501759675-restore"
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  sku_name                  = "B_Gen5_2"
  version                   = "10.3"
  create_mode               = "PointInTimeRestore"
  creation_source_server_id = azurerm_mariadb_server.test.id
  restore_point_in_time     = "2023-09-22T06:29:01Z"
  ssl_enforcement_enabled   = true
  storage_mb                = 51200
}
