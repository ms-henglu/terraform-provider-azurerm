

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-230526085348255460"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-230526085348255460"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
