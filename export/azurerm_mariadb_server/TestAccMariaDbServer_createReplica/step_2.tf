

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034258957638"
  location = "West Europe"
}

resource "azurerm_mariadb_server" "test" {
  name                = "acctestmariadbsvr-231016034258957638"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "B_Gen5_2"
  version             = "10.3"

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"
  ssl_enforcement_enabled      = true
  storage_mb                   = 51200
}


resource "azurerm_mariadb_server" "replica" {
  name                      = "acctestmariadbsvr-231016034258957638-replica"
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  sku_name                  = "B_Gen5_2"
  version                   = "10.3"
  create_mode               = "Replica"
  creation_source_server_id = azurerm_mariadb_server.test.id
  ssl_enforcement_enabled   = true
  storage_mb                = 51200
}
