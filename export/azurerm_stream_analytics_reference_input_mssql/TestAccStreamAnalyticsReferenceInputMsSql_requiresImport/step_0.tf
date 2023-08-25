

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825025417730591"
  location = "West Europe"
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-230825025417730591"
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

resource "azurerm_mssql_server" "test" {
  name                         = "acctest-sqlserver-230825025417730591"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

resource "azurerm_mssql_database" "test" {
  name         = "acctest-db-230825025417730591"
  server_id    = azurerm_mssql_server.test.id
  license_type = "LicenseIncluded"
}


resource "azurerm_stream_analytics_reference_input_mssql" "test" {
  name                      = "acctestinput-230825025417730591"
  stream_analytics_job_name = azurerm_stream_analytics_job.test.name
  resource_group_name       = azurerm_stream_analytics_job.test.resource_group_name
  server                    = azurerm_mssql_server.test.fully_qualified_domain_name
  database                  = azurerm_mssql_database.test.name
  username                  = "maurice"
  password                  = "ludicrousdisplay"
  refresh_type              = "RefreshPeriodicallyWithFull"
  refresh_interval_duration = "00:10:00"
  full_snapshot_query       = <<QUERY
   SELECT *
   INTO [YourOutputAlias]
   FROM [YourInputAlias]
QUERY

}
