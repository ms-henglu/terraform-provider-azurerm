


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034354348341"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver221021034354348341"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "msincredible"
  administrator_login_password = "P@55W0rD!!s94i2"

  outbound_network_restriction_enabled = true
}


resource "azurerm_mssql_outbound_firewall_rule" "test" {
  name      = "sql221021034354348341.database.windows.net"
  server_id = azurerm_mssql_server.test.id
}


resource "azurerm_mssql_outbound_firewall_rule" "import" {
  name      = azurerm_mssql_outbound_firewall_rule.test.name
  server_id = azurerm_mssql_outbound_firewall_rule.test.server_id
}
