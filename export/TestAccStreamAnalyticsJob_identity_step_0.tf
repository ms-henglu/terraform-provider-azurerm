
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210025135478854"
  location = "West Europe"
}

resource "azurerm_stream_analytics_job" "test" {
  name                = "acctestjob-211210025135478854"
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
