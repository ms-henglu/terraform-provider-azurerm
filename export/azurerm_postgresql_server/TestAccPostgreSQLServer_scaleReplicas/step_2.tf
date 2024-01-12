

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-240112225052553901"
  location = "West Europe"
}

resource "azurerm_postgresql_server" "test" {
  name                = "acctest-psql-server-240112225052553901"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "GP_Gen5_4"
  version    = "11"
  storage_mb = 51200

  ssl_enforcement_enabled = true
}


resource "azurerm_resource_group" "replica1" {
  name     = "acctestRG-psql-240112225052553901-replica1"
  location = "West US 2"
}

resource "azurerm_postgresql_server" "replica1" {
  name                = "acctest-psql-server-240112225052553901-replica1"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.replica1.name

  sku_name = "GP_Gen5_4"
  version  = "11"

  create_mode               = "Replica"
  creation_source_server_id = azurerm_postgresql_server.test.id

  ssl_enforcement_enabled = true
}

resource "azurerm_postgresql_server" "replica2" {
  name                = "acctest-psql-server-240112225052553901-replica2"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "GP_Gen5_4"
  version  = "11"

  create_mode               = "Replica"
  creation_source_server_id = azurerm_postgresql_server.test.id

  ssl_enforcement_enabled = true
}
