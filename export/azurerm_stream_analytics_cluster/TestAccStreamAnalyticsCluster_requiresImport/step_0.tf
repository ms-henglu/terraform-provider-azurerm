

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630034041336988"
  location = "West Europe"
}


resource "azurerm_stream_analytics_cluster" "test" {
  name                = "acctestcluster-230630034041336988"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  streaming_capacity  = 36
}
