


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025436781162"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver240119025436781162"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "msincredible"
  administrator_login_password = "P@55W0rD!!abwe7"
}


resource "azurerm_mssql_firewall_rule" "test" {
  name             = "acctestsqlserver240119025436781162"
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
