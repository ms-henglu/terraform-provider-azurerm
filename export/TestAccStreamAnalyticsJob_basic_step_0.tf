
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072448238693"
  location = "West Europe"
}

resource "azurerm_stream_analytics_job" "test" {
  name                = "acctestjob-211013072448238693"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  streaming_units     = 3

  tags = {
    environment = "Test"
  }

  transformation_query = <<QUERY
    SELECT *
    INTO [YourOutputAlias]
    FROM [YourInputAlias]
QUERY

}
