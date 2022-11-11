
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111014344394779"
  location = "West Europe"
}

resource "azurerm_stream_analytics_job" "test" {
  name                = "acctestjob-221111014344394779"
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
