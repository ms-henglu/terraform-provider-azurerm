
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929065822541483"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccpo1tu"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_stream_analytics_job" "test" {
  name                   = "acctestjob-230929065822541483"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  streaming_units        = 3
  content_storage_policy = "JobStorageAccount"
  job_storage_account {
    account_name = azurerm_storage_account.test.name
    account_key  = azurerm_storage_account.test.primary_access_key
  }

  tags = {
    environment = "Test"
  }

  transformation_query = <<QUERY
    SELECT *
    INTO [YourOutputAlias]
    FROM [YourInputAlias]
QUERY

}
