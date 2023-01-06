

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031724447462"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver230106031724447462"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "msincredible"
  administrator_login_password = "P@55W0rD!!rrlw9"
}


resource "azurerm_mssql_firewall_rule" "test" {
  name             = "acctestsqlserver230106031724447462"
  server_id        = azurerm_mssql_server.test.id
  start_ip_address = "10.0.17.62"
  end_ip_address   = "10.0.17.64"
}
