

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-psql-230922061732443126"
  location = "West Europe"
}

resource "azurerm_postgresql_server" "test" {
  name                = "acctest-psql-server-230922061732443126"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "GP_Gen5_2"

  storage_mb                   = 51200
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  administrator_login          = "acctestun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "9.6"
  ssl_enforcement_enabled      = true
}


resource "azurerm_postgresql_configuration" "test" {
  name                = "idle_in_transaction_session_timeout"
  resource_group_name = azurerm_postgresql_server.test.resource_group_name
  server_name         = azurerm_postgresql_server.test.name
  value               = "60"
}

resource "azurerm_postgresql_configuration" "test2" {
  name                = "log_autovacuum_min_duration"
  resource_group_name = azurerm_postgresql_server.test.resource_group_name
  server_name         = azurerm_postgresql_server.test.name
  value               = "10"
}

resource "azurerm_postgresql_configuration" "test3" {
  name                = "log_lock_waits"
  resource_group_name = azurerm_postgresql_server.test.resource_group_name
  server_name         = azurerm_postgresql_server.test.name
  value               = "on"
}

resource "azurerm_postgresql_configuration" "test4" {
  name                = "log_min_duration_statement"
  resource_group_name = azurerm_postgresql_server.test.resource_group_name
  server_name         = azurerm_postgresql_server.test.name
  value               = "10"
}

resource "azurerm_postgresql_configuration" "test5" {
  name                = "log_statement"
  resource_group_name = azurerm_postgresql_server.test.resource_group_name
  server_name         = azurerm_postgresql_server.test.name
  value               = "ddl"
}

resource "azurerm_postgresql_configuration" "test6" {
  name                = "pg_stat_statements.track"
  resource_group_name = azurerm_postgresql_server.test.resource_group_name
  server_name         = azurerm_postgresql_server.test.name
  value               = "top"
}

resource "azurerm_postgresql_configuration" "test7" {
  name                = "pg_qs.query_capture_mode"
  resource_group_name = azurerm_postgresql_server.test.resource_group_name
  server_name         = azurerm_postgresql_server.test.name
  value               = "top"
}

resource "azurerm_postgresql_configuration" "test8" {
  name                = "pgms_wait_sampling.query_capture_mode"
  resource_group_name = azurerm_postgresql_server.test.resource_group_name
  server_name         = azurerm_postgresql_server.test.name
  value               = "all"
}

resource "azurerm_postgresql_configuration" "test9" {
  name                = "pg_qs.max_query_text_length"
  resource_group_name = azurerm_postgresql_server.test.resource_group_name
  server_name         = azurerm_postgresql_server.test.name
  value               = 10000
}

resource "azurerm_postgresql_configuration" "test10" {
  name                = "pg_qs.retention_period_in_days"
  resource_group_name = azurerm_postgresql_server.test.resource_group_name
  server_name         = azurerm_postgresql_server.test.name
  value               = 30
}
