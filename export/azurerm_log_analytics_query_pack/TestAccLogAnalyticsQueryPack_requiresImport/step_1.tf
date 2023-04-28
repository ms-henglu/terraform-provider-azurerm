


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-230428050018755682"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-230428050018755682"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_log_analytics_query_pack" "import" {
  name                = azurerm_log_analytics_query_pack.test.name
  resource_group_name = azurerm_log_analytics_query_pack.test.resource_group_name
  location            = azurerm_log_analytics_query_pack.test.location
}
