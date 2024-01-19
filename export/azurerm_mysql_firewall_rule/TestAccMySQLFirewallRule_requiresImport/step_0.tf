
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025452496122"
  location = "West Europe"
}

resource "azurerm_mysql_server" "test" {
  name                = "acctestmysqlsvr-240119025452496122"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "GP_Gen5_2"

  storage_mb                   = 51200
  geo_redundant_backup_enabled = false
  backup_retention_days        = 7

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "5.7"
  ssl_enforcement_enabled      = true
}

resource "azurerm_mysql_firewall_rule" "test" {
  name                = "acctestfwrule-240119025452496122"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_mysql_server.test.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
