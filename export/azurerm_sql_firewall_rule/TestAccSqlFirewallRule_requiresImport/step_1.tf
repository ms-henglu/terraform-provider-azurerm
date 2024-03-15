

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315124123541128"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver240315124123541128"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_firewall_rule" "test" {
  name                = "acctestsqlserver240315124123541128"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_sql_server.test.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}


resource "azurerm_sql_firewall_rule" "import" {
  name                = azurerm_sql_firewall_rule.test.name
  resource_group_name = azurerm_sql_firewall_rule.test.resource_group_name
  server_name         = azurerm_sql_firewall_rule.test.server_name
  start_ip_address    = azurerm_sql_firewall_rule.test.start_ip_address
  end_ip_address      = azurerm_sql_firewall_rule.test.end_ip_address
}
