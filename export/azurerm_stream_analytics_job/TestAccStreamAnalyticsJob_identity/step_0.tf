
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117231557418404"
  location = "West Europe"
}

resource "azurerm_stream_analytics_job" "test" {
  name                = "acctestjob-221117231557418404"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  streaming_units     = 3

  transformation_query = <<QUERY
    SELECT *
    INTO [YourOutputAlias]
    FROM [YourInputAlias]
QUERY

  identity {
    type = "SystemAssigned"
  }
}
