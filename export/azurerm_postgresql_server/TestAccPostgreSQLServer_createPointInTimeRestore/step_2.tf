

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-230915024016227563"
  location = "West Europe"
}

resource "azurerm_postgresql_server" "test" {
  name                = "acctest-psql-server-230915024016227563"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "GP_Gen5_2"
  version    = "11"
  storage_mb = 51200

  ssl_enforcement_enabled = true
}


resource "azurerm_postgresql_server" "restore" {
  name                = "acctest-psql-server-230915024016227563-restore"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name   = "GP_Gen5_2"
  version    = "11"
  storage_mb = 51200

  create_mode               = "PointInTimeRestore"
  creation_source_server_id = azurerm_postgresql_server.test.id
  restore_point_in_time     = "2023-09-15T03:40:16Z"

  ssl_enforcement_enabled       = true
  public_network_access_enabled = false
}
