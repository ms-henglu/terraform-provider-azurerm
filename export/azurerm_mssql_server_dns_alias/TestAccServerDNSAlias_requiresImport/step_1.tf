



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appServerDNSAlias-230414021807384254"
  location = "West Europe"
}

resource "azurerm_mssql_server" "sql" {
  administrator_login          = "umtacc"
  administrator_login_password = "random81jdpwd_$#fs"
  location                     = azurerm_resource_group.test.location
  name                         = "acctestrg-sql-sever-230414021807384254"
  resource_group_name          = azurerm_resource_group.test.name
  version                      = "12.0"
}

resource "azurerm_mssql_server_dns_alias" "test" {
  mssql_server_id = azurerm_mssql_server.sql.id
  name            = "acctest-dns-alias-230414021807384254"
}


resource "azurerm_mssql_server_dns_alias" "import" {
  name            = azurerm_mssql_server_dns_alias.test.name
  mssql_server_id = azurerm_mssql_server_dns_alias.test.mssql_server_id
}
