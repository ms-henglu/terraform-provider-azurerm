

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-240119025622765359"
  location = "West Europe"
}

resource "azurerm_postgresql_server" "test" {
  name                = "acctest-psql-server-240119025622765359"
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

resource "azurerm_postgresql_active_directory_administrator" "test" {
  server_name         = azurerm_postgresql_server.test.name
  resource_group_name = azurerm_resource_group.test.name
  login               = "sqladmin"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.client_id
}


resource "azurerm_postgresql_active_directory_administrator" "import" {
  server_name         = azurerm_postgresql_active_directory_administrator.test.server_name
  resource_group_name = azurerm_postgresql_active_directory_administrator.test.resource_group_name
  login               = azurerm_postgresql_active_directory_administrator.test.login
  tenant_id           = azurerm_postgresql_active_directory_administrator.test.tenant_id
  object_id           = azurerm_postgresql_active_directory_administrator.test.object_id
}
