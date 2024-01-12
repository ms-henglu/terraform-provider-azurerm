

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-240112225052552888"
  location = "West Europe"
}

resource "azurerm_postgresql_server" "test" {
  name                = "acctest-psql-server-240112225052552888"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_1"
  version    = "10.0"
  storage_mb = 51200

  ssl_enforcement_enabled = true
}


resource "azurerm_postgresql_server" "import" {
  name                = azurerm_postgresql_server.test.name
  location            = azurerm_postgresql_server.test.location
  resource_group_name = azurerm_postgresql_server.test.resource_group_name

  administrator_login          = azurerm_postgresql_server.test.administrator_login
  administrator_login_password = azurerm_postgresql_server.test.administrator_login_password

  sku_name   = azurerm_postgresql_server.test.sku_name
  version    = azurerm_postgresql_server.test.version
  storage_mb = azurerm_postgresql_server.test.storage_mb

  ssl_enforcement_enabled = azurerm_postgresql_server.test.ssl_enforcement_enabled
}
