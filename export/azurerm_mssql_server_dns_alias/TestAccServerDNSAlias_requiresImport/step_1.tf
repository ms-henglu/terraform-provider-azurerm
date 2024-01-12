



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appServerDNSAlias-240112034811674975"
  location = "West Europe"
}

resource "azurerm_mssql_server" "sql" {
  administrator_login          = "umtacc"
  administrator_login_password = "random81jdpwd_$#fs"
  location                     = azurerm_resource_group.test.location
  name                         = "acctestrg-sql-sever-240112034811674975"
  resource_group_name          = azurerm_resource_group.test.name
  version                      = "12.0"
}

resource "azurerm_mssql_server_dns_alias" "test" {
  mssql_server_id = azurerm_mssql_server.sql.id
  name            = "acctest-dns-alias-240112034811674975"
}


resource "azurerm_mssql_server_dns_alias" "import" {
  name            = azurerm_mssql_server_dns_alias.test.name
  mssql_server_id = azurerm_mssql_server_dns_alias.test.mssql_server_id
}
