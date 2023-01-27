

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-230127045642197408"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-230127045642197408"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
