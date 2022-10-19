

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-221019054524088945"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-221019054524088945"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
