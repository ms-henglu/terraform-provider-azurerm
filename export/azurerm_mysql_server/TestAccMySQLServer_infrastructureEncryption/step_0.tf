
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061601556495"
  location = "West Europe"
}

resource "azurerm_mysql_server" "test" {
  name                              = "acctestmysqlsvr-230922061601556495"
  location                          = azurerm_resource_group.test.location
  resource_group_name               = azurerm_resource_group.test.name
  sku_name                          = "GP_Gen5_2"
  administrator_login               = "acctestun"
  administrator_login_password      = "H@Sh1CoR3!"
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_1"
  storage_mb                        = 51200
  version                           = "5.7"
  infrastructure_encryption_enabled = true
}
