

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034356094751"
  location = "West Europe"
}

resource "azurerm_mysql_flexible_server" "test" {
  name                   = "acctest-fs-231016034356094751"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  sku_name               = "B_Standard_B1s"
  zone                   = "1"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "test" {
  name                = "acctestfwrule-231016034356094751"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_mysql_flexible_server.test.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}


resource "azurerm_mysql_flexible_server_firewall_rule" "import" {
  name                = azurerm_mysql_flexible_server_firewall_rule.test.name
  resource_group_name = azurerm_mysql_flexible_server_firewall_rule.test.resource_group_name
  server_name         = azurerm_mysql_flexible_server_firewall_rule.test.server_name
  start_ip_address    = azurerm_mysql_flexible_server_firewall_rule.test.start_ip_address
  end_ip_address      = azurerm_mysql_flexible_server_firewall_rule.test.end_ip_address
}
