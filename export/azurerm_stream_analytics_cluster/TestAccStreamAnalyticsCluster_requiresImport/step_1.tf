


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311033322864034"
  location = "West Europe"
}


resource "azurerm_stream_analytics_cluster" "test" {
  name                = "acctestcluster-240311033322864034"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  streaming_capacity  = 36
}


resource "azurerm_stream_analytics_cluster" "import" {
  name                = azurerm_stream_analytics_cluster.test.name
  resource_group_name = azurerm_stream_analytics_cluster.test.resource_group_name
  location            = azurerm_stream_analytics_cluster.test.location
  streaming_capacity  = azurerm_stream_analytics_cluster.test.streaming_capacity
}
