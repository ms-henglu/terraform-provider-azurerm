
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025846923635"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver240119025846923635"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_firewall_rule" "test" {
  name                = "acctestsqlserver240119025846923635"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_sql_server.test.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
