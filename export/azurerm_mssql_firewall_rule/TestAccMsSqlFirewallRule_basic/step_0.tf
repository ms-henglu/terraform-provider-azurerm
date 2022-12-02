

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202040106490219"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver221202040106490219"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "msincredible"
  administrator_login_password = "P@55W0rD!!lb9k6"
}


resource "azurerm_mssql_firewall_rule" "test" {
  name             = "acctestsqlserver221202040106490219"
  server_id        = azurerm_mssql_server.test.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
