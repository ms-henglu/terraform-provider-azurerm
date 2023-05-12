

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512011103276491"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver230512011103276491"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "msincredible"
  administrator_login_password = "P@55W0rD!!rkjeu"

  outbound_network_restriction_enabled = true
}


resource "azurerm_mssql_outbound_firewall_rule" "test" {
  name      = "sql230512011103276491.database.windows.net"
  server_id = azurerm_mssql_server.test.id
}
