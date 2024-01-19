

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LA-240119025258338616"
  location = "West Europe"
}


resource "azurerm_log_analytics_query_pack" "test" {
  name                = "acctestlaqp-240119025258338616"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    ENV = "Test1"
  }
}
