

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916012119440347"
  location = "West Europe"
}


resource "azurerm_stream_analytics_cluster" "test" {
  name                = "acctestcluster-220916012119440347"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  streaming_capacity  = 36
}
