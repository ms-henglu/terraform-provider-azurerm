


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230203063759750976"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver230203063759750976"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "msincredible"
  administrator_login_password = "P@55W0rD!!o28ll"

  outbound_network_restriction_enabled = true
}


resource "azurerm_mssql_outbound_firewall_rule" "test" {
  name      = "sql230203063759750976.database.windows.net"
  server_id = azurerm_mssql_server.test.id
}


resource "azurerm_mssql_outbound_firewall_rule" "import" {
  name      = azurerm_mssql_outbound_firewall_rule.test.name
  server_id = azurerm_mssql_outbound_firewall_rule.test.server_id
}
