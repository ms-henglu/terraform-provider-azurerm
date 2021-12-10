

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210025135461697"
  location = "West Europe"
}


resource "azurerm_stream_analytics_cluster" "test" {
  name                = "acctestcluster-211210025135461697"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  streaming_capacity  = 36
}
