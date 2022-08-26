

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-220826002921117772"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-220826002921117772"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
