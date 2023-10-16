

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034840934663"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsasmfrm"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  location                 = "${azurerm_resource_group.test.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "example"
  storage_account_name  = "${azurerm_storage_account.test.name}"
  container_access_type = "private"
}

resource "azurerm_stream_analytics_job" "test" {
  name                                     = "acctestjob-231016034840934663"
  resource_group_name                      = "${azurerm_resource_group.test.name}"
  location                                 = "${azurerm_resource_group.test.location}"
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


resource "azurerm_stream_analytics_stream_input_blob" "test" {
  name                      = "acctestinput-231016034840934663"
  stream_analytics_job_name = azurerm_stream_analytics_job.test.name
  resource_group_name       = azurerm_stream_analytics_job.test.resource_group_name
  storage_account_name      = azurerm_storage_account.test.name
  storage_account_key       = azurerm_storage_account.test.primary_access_key
  storage_container_name    = azurerm_storage_container.test.name
  path_pattern              = "some-random-pattern"
  date_format               = "yyyy/MM/dd"
  time_format               = "HH"

  serialization {
    type = "Avro"
  }
}
