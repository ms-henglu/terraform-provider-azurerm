

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-240311032422802212"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-240311032422802212"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
