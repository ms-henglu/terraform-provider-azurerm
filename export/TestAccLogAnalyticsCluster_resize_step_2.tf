

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-220610022743742248"
  location = "West Europe"
}


resource "azurerm_log_analytics_cluster" "test" {
  name                = "acctest-LA-220610022743742248"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size_gb             = 1100

  identity {
    type = "SystemAssigned"
  }
}
