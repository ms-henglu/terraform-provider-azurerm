
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204901180729"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestsqlserver221221204901180729"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_database" "test" {
  name                             = "acctestdb221221204901180729"
  resource_group_name              = azurerm_resource_group.test.name
  server_name                      = azurerm_sql_server.test.name
  location                         = azurerm_resource_group.test.location
  edition                          = "Standard"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  max_size_bytes                   = "1073741824"
  requested_service_objective_name = "S0"
}

resource "azurerm_sql_database" "test_restore" {
  name                  = "acctestdb_restore221221204901180729"
  resource_group_name   = azurerm_resource_group.test.name
  server_name           = azurerm_sql_server.test.name
  location              = azurerm_resource_group.test.location
  create_mode           = "PointInTimeRestore"
  source_database_id    = azurerm_sql_database.test.id
  restore_point_in_time = "2022-12-21T21:04:01Z"
}
