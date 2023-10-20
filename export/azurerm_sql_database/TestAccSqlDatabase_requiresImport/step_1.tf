

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041927516993"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver231020041927516993"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_database" "test" {
  name                             = "acctestdb231020041927516993"
  resource_group_name              = azurerm_resource_group.test.name
  server_name                      = azurerm_sql_server.test.name
  location                         = azurerm_resource_group.test.location
  edition                          = "Standard"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  max_size_bytes                   = "1073741824"
  requested_service_objective_name = "S0"
}


resource "azurerm_sql_database" "import" {
  name                             = azurerm_sql_database.test.name
  resource_group_name              = azurerm_sql_database.test.resource_group_name
  server_name                      = azurerm_sql_database.test.server_name
  location                         = azurerm_sql_database.test.location
  edition                          = azurerm_sql_database.test.edition
  collation                        = azurerm_sql_database.test.collation
  max_size_bytes                   = azurerm_sql_database.test.max_size_bytes
  requested_service_objective_name = azurerm_sql_database.test.requested_service_objective_name
}
