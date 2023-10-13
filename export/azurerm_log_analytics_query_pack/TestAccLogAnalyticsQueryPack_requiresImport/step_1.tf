


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-231013043726002632"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-231013043726002632"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_log_analytics_query_pack" "import" {
  name                = azurerm_log_analytics_query_pack.test.name
  resource_group_name = azurerm_log_analytics_query_pack.test.resource_group_name
  location            = azurerm_log_analytics_query_pack.test.location
}
