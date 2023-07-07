
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707011013297197"
  location = "West Europe"
}

resource "azurerm_sql_server" "test_primary" {
  name                         = "acctestmssql230707011013297197-primary"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_server" "test_secondary" {
  name                         = "acctestmssql230707011013297197-secondary"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = "West US 2"
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_database" "test" {
  name                             = "acctestdb230707011013297197"
  resource_group_name              = azurerm_resource_group.test.name
  server_name                      = azurerm_sql_server.test_primary.name
  location                         = azurerm_resource_group.test.location
  edition                          = "Standard"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  max_size_bytes                   = "1073741824"
  requested_service_objective_name = "S0"
}

resource "azurerm_sql_failover_group" "test" {
  name                = "acctestsfg230707011013297197"
  resource_group_name = azurerm_resource_group.test.name
  server_name         = azurerm_sql_server.test_primary.name
  databases           = [azurerm_sql_database.test.id]

  partner_servers {
    id = azurerm_sql_server.test_secondary.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }
}
