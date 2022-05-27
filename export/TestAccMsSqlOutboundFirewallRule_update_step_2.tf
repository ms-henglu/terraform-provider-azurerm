

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034449085049"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver220527034449085049"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "msincredible"
  administrator_login_password = "P@55W0rD!!9ajbh"

  outbound_network_restriction_enabled = true
}


resource "azurerm_mssql_outbound_firewall_rule" "test" {
  name      = "sql220527034449085049.database.windows.net"
  server_id = azurerm_mssql_server.test.id
}

resource "azurerm_mssql_outbound_firewall_rule" "test2" {
  name      = "sql2220527034449085049.database.windows.net"
  server_id = azurerm_mssql_server.test.id
}
