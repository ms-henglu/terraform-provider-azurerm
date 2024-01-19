

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025436784859"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver240119025436784859"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "msincredible"
  administrator_login_password = "P@55W0rD!!r07rq"
}


resource "azurerm_mssql_firewall_rule" "test" {
  name             = "acctestsqlserver240119025436784859"
  server_id        = azurerm_mssql_server.test.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
