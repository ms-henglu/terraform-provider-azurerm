

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-221216013738172085"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-221216013738172085"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
