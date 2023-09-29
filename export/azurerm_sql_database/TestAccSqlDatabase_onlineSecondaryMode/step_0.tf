
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sql-230929065745789081-p"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver230929065745789081"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_database" "test" {
  name                             = "acctestdb230929065745789081"
  resource_group_name              = azurerm_resource_group.test.name
  server_name                      = azurerm_sql_server.test.name
  location                         = azurerm_resource_group.test.location
  edition                          = "Standard"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  max_size_bytes                   = "1073741824"
  requested_service_objective_name = "S0"
}

resource "azurerm_resource_group" "test2" {
  name     = "acctestRG-sql-230929065745789081-s"
  location = "West US 2"
}

resource "azurerm_sql_server" "test2" {
  name                         = "acctestsqlserver2230929065745789081"
  resource_group_name          = azurerm_resource_group.test2.name
  location                     = azurerm_resource_group.test2.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_database" "test2" {
  name                = "acctestdb2230929065745789081"
  resource_group_name = azurerm_resource_group.test2.name
  server_name         = azurerm_sql_server.test2.name
  location            = azurerm_resource_group.test2.location
  create_mode         = "OnlineSecondary"
  source_database_id  = azurerm_sql_database.test.id
}
