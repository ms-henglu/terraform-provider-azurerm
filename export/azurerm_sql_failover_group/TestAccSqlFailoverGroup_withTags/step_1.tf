
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072614070091"
  location = "West Europe"
}

resource "azurerm_sql_server" "test_primary" {
  name                         = "acctestmssql231218072614070091-primary"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_server" "test_secondary" {
  name                         = "acctestmssql231218072614070091-secondary"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = "West US 2"
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_sql_database" "test" {
  name                             = "acctestdb231218072614070091"
  resource_group_name              = azurerm_resource_group.test.name
  server_name                      = azurerm_sql_server.test_primary.name
  location                         = azurerm_resource_group.test.location
  edition                          = "Standard"
  collation                        = "SQL_Latin1_General_CP1_CI_AS"
  max_size_bytes                   = "1073741824"
  requested_service_objective_name = "S0"
}

resource "azurerm_sql_failover_group" "test" {
  name                = "acctestsfg231218072614070091"
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
  tags = {
    environment = "production"
  }
}
