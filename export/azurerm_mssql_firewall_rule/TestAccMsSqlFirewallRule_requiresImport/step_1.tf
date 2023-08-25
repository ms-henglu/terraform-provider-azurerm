


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024940433053"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver230825024940433053"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "msincredible"
  administrator_login_password = "P@55W0rD!!l3j4b"
}


resource "azurerm_mssql_firewall_rule" "test" {
  name             = "acctestsqlserver230825024940433053"
  server_id        = azurerm_mssql_server.test.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}


resource "azurerm_mssql_firewall_rule" "import" {
  name             = azurerm_mssql_firewall_rule.test.name
  server_id        = azurerm_mssql_firewall_rule.test.server_id
  start_ip_address = azurerm_mssql_firewall_rule.test.start_ip_address
  end_ip_address   = azurerm_mssql_firewall_rule.test.end_ip_address
}
