

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-211013072032219169"
  location = "West Europe"
}


resource "azurerm_log_analytics_cluster" "test" {
  name                = "acctest-LA-211013072032219169"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
