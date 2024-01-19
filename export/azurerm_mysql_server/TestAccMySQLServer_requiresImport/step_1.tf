

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025452514047"
  location = "West Europe"
}

resource "azurerm_mysql_server" "test" {
  name                             = "acctestmysqlsvr-240119025452514047"
  location                         = azurerm_resource_group.test.location
  resource_group_name              = azurerm_resource_group.test.name
  sku_name                         = "GP_Gen5_2"
  administrator_login              = "acctestun"
  administrator_login_password     = "H@Sh1CoR3!"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_1"
  storage_mb                       = 51200
  version                          = "5.7"
}


resource "azurerm_mysql_server" "import" {
  name                = azurerm_mysql_server.test.name
  location            = azurerm_mysql_server.test.location
  resource_group_name = azurerm_mysql_server.test.resource_group_name
  sku_name            = "GP_Gen5_2"
  version             = "5.7"

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  ssl_enforcement_enabled      = true
  storage_mb                   = 51200
}
