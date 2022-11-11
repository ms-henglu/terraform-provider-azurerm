

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-221111013756812840"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-221111013756812840"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
