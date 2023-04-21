


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421023026424629"
  location = "West Europe"
}

resource "azurerm_sql_server" "test" {
  name                         = "acctestserver-6f368"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "acctestadmin"
  administrator_login_password = "t2RX8A76GrnE4EKC"
}

resource "azurerm_sql_database" "test" {
  name                             = "acctestdb"
  resource_group_name              = azurerm_resource_group.test.name
  location                         = azurerm_resource_group.test.location
  server_name                      = azurerm_sql_server.test.name
  requested_service_objective_name = "S0"
  collation                        = "SQL_LATIN1_GENERAL_CP1_CI_AS"
  max_size_bytes                   = "268435456000"
  create_mode                      = "Default"
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-6f368"
  resource_group_name                      = azurerm_resource_group.test.name
  location                                 = azurerm_resource_group.test.location
  compatibility_level                      = "1.0"
  data_locale                              = "en-GB"
  events_late_arrival_max_delay_in_seconds = 60
  events_out_of_order_max_delay_in_seconds = 50
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Drop"
  streaming_units                          = 3

  transformation_query = <<QUERY
    SELECT *
    INTO [YourOutputAlias]
    FROM [YourInputAlias]
QUERY

}


resource "azurerm_stream_analytics_output_mssql" "test" {
  name                      = "acctestoutput-230421023026424629"
  stream_analytics_job_name = azurerm_stream_analytics_job.test.name
  resource_group_name       = azurerm_stream_analytics_job.test.resource_group_name

  server   = azurerm_sql_server.test.fully_qualified_domain_name
  user     = azurerm_sql_server.test.administrator_login
  password = azurerm_sql_server.test.administrator_login_password
  database = azurerm_sql_database.test.name
  table    = "AccTestTable"
}


resource "azurerm_stream_analytics_output_mssql" "import" {
  name                      = azurerm_stream_analytics_output_mssql.test.name
  stream_analytics_job_name = azurerm_stream_analytics_output_mssql.test.stream_analytics_job_name
  resource_group_name       = azurerm_stream_analytics_output_mssql.test.resource_group_name

  server   = azurerm_sql_server.test.fully_qualified_domain_name
  user     = azurerm_sql_server.test.administrator_login
  password = azurerm_sql_server.test.administrator_login_password
  database = azurerm_sql_database.test.name
  table    = "AccTestTable"
}
