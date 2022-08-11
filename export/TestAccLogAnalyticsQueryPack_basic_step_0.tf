

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-220811053452436930"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-220811053452436930"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
