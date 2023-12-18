

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072223083326"
  location = "West Europe"
}

resource "azurerm_mysql_server" "test" {
  name                = "acctestmysqlsvr-231218072223083326"
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
  name                = "acctestfwrule-231218072223083326"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_mysql_server.test.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}


resource "azurerm_mysql_firewall_rule" "import" {
  name                = azurerm_mysql_firewall_rule.test.name
  resource_group_name = azurerm_mysql_firewall_rule.test.resource_group_name
  server_name         = azurerm_mysql_firewall_rule.test.server_name
  start_ip_address    = azurerm_mysql_firewall_rule.test.start_ip_address
  end_ip_address      = azurerm_mysql_firewall_rule.test.end_ip_address
}
