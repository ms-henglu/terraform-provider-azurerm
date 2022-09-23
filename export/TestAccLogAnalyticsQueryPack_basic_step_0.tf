

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-220923012019638978"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-220923012019638978"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
