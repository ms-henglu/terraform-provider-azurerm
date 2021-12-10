

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-211210024925852117"
  location = "West Europe"
}

resource "azurerm_postgresql_server" "test" {
  name                = "acctest-psql-server-211210024925852117"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_1"
  version    = "11"
  storage_mb = 51200

  ssl_enforcement_enabled = true
}


resource "azurerm_postgresql_server" "restore" {
  name                = "acctest-psql-server-211210024925852117-restore"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name   = "GP_Gen5_2"
  version    = "11"
  storage_mb = 51200

  create_mode               = "PointInTimeRestore"
  creation_source_server_id = azurerm_postgresql_server.test.id
  restore_point_in_time     = "2021-12-10T03:49:25Z"

  ssl_enforcement_enabled = true
}
