

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013930820054"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver221111013930820054"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "msincredible"
  administrator_login_password = "P@55W0rD!!0xop7"
}


resource "azurerm_mssql_firewall_rule" "test" {
  name             = "acctestsqlserver221111013930820054"
  server_id        = azurerm_mssql_server.test.id
  start_ip_address = "10.0.17.62"
  end_ip_address   = "10.0.17.64"
}
