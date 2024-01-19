

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mssql-240119025436780492"
  location = "West Europe"
}

resource "azurerm_mssql_server" "test" {
  name                         = "acctestsqlserver240119025436780492"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "thisIsKat11"

  outbound_network_restriction_enabled = true
}


resource "azurerm_mssql_server" "import" {
  name                         = azurerm_mssql_server.test.name
  resource_group_name          = azurerm_mssql_server.test.resource_group_name
  location                     = azurerm_mssql_server.test.location
  version                      = azurerm_mssql_server.test.version
  administrator_login          = azurerm_mssql_server.test.administrator_login
  administrator_login_password = azurerm_mssql_server.test.administrator_login_password
}
