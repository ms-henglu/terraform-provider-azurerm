
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014851750024"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver211015014851750024"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_database" "test" {
  name                             = "acctestdb211015014851750024"
  resource_group_name              = azurerm_resource_group.test.name
  server_name                      = azurerm_sql_server.test.name
  location                         = azurerm_resource_group.test.location
  edition                          = "Standard"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  max_size_bytes                   = "1073741824"
  requested_service_objective_name = "S0"
}
