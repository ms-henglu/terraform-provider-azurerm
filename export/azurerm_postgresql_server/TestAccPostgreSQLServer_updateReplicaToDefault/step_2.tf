

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-230929065511046181"
  location = "West Europe"
}

resource "azurerm_postgresql_server" "test" {
  name                = "acctest-psql-server-230929065511046181"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "GP_Gen5_2"
  version    = "11"
  storage_mb = 51200

  ssl_enforcement_enabled = true
}


resource "azurerm_resource_group" "replica" {
  name     = "acctestRG-psql-230929065511046181-replica"
  location = "West US 2"
}

resource "azurerm_postgresql_server" "replica" {
  name                = "acctest-psql-server-230929065511046181-replica"
  location            = "West US 2"
  resource_group_name = azurerm_resource_group.replica.name

  sku_name    = "GP_Gen5_2"
  version     = "11"
  create_mode = "Default"

  public_network_access_enabled = false
  ssl_enforcement_enabled       = true
}
