
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512011518710377"
  location = "West Europe"
}

resource "azurerm_stream_analytics_job" "test" {
  name                = "acctestjob-230512011518710377"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  streaming_units     = 3
  type                = "Cloud"

  transformation_query = <<QUERY
    SELECT *
    INTO [YourOutputAlias]
    FROM [YourInputAlias]
QUERY
}
