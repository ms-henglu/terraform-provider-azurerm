

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315124123534478"
  location = "West Europe"
}

resource "azurerm_sql_server" "test_primary" {
  name                         = "acctestmssql240315124123534478-primary"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_server" "test_secondary" {
  name                         = "acctestmssql240315124123534478-secondary"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = "West US 2"
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_database" "test" {
  name                             = "acctestdb240315124123534478"
  resource_group_name              = azurerm_resource_group.test.name
  server_name                      = azurerm_sql_server.test_primary.name
  location                         = azurerm_resource_group.test.location
  edition                          = "Standard"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  max_size_bytes                   = "1073741824"
  requested_service_objective_name = "S0"
}

resource "azurerm_sql_failover_group" "test" {
  name                = "acctestsfg240315124123534478"
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


resource "azurerm_sql_failover_group" "import" {
  name                = azurerm_sql_failover_group.test.name
  resource_group_name = azurerm_sql_failover_group.test.resource_group_name
  server_name         = azurerm_sql_failover_group.test.server_name
  databases           = azurerm_sql_failover_group.test.databases

  partner_servers {
    id = azurerm_sql_failover_group.test.partner_servers[0].id
  }

  read_write_endpoint_failover_policy {
    mode          = azurerm_sql_failover_group.test.read_write_endpoint_failover_policy[0].mode
    grace_minutes = azurerm_sql_failover_group.test.read_write_endpoint_failover_policy[0].grace_minutes
  }
}
