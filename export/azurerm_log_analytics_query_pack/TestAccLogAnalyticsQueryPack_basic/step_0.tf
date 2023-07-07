

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-230707004205581863"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-230707004205581863"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
